classdef device
    %�����࣬�ɶ��Ĥ��ɣ���Ҫ����film����
    %   ������������ϴ�ֱ���䣬������Ŵ�����������
    %   �����������߽�������Ĭ��Ϊ���
    properties
        LayerN;     %�����������缫��
        surrounding_up;%�������ϱ߽�����nk(�������)
        surrounding_down;%�±߽�����nk(�������)
        Layers;     %film����
        Absorb_sun; %̫�������հٷֱ�
        %-------------��¼�м�ֵ----------
        r_s;          %s�������������
        t_s;          %s�������͸����
        r_p;          %p�������������
        t_p;          %p�������͸����
        R;          %������:��С��1*wavelength�ľ���
        T;          %͸����:��С��1*wavelength�ľ���
        A;          %������:��С��1*wavelength�ľ���
        f_z;        %���ֵ,˳�����¼����
        I_z;        %���ֵ,˳�����¼����
        %-----------------------------------------
        err;        %ģ�����

    end
    
	methods
        %---------------------------------------
        %------------�������캯��--------------
        %------------------------------------
        function obj=device(l)
            %���캯��
            global MaxL MinL            
            obj.LayerN=0;
            obj.surrounding_up=zeros(MaxL-MinL+1,3);
            obj.surrounding_up(:,1)=MinL:MaxL;
            obj.surrounding_up(:,2)=1.0;%��ջ���
            obj.surrounding_up(:,3)=0;%��ջ���
            obj.surrounding_down=zeros(MaxL-MinL+1,3);
            obj.surrounding_down(:,1)=MinL:MaxL;
            obj.surrounding_down(:,2)=1.5;%glass����
            obj.surrounding_down(:,3)=0;%glass����
            obj.Layers=[];
            obj.R=zeros(1,MaxL-MinL+1);
            obj.T=zeros(1,MaxL-MinL+1);
            obj.A=zeros(1,MaxL-MinL+1);
            obj.t_s=zeros(1,MaxL-MinL+1);
            obj.r_s=zeros(1,MaxL-MinL+1);

            d=zeros(1,obj.LayerN);
            if nargin==0
                return
            end
            if nargin==1
                obj=AddLayer(obj,l);
            end
        end
        function obj=AddLayer(obj,l)
            %����һ���µĲ�,l��film���һ������
            %�����ǵ�һ��
            s=size(l);
            n=s(2);%l��ά��
            for i=1:n
                obj.LayerN=obj.LayerN+1;
                if obj.LayerN==1%%%%%��������׳���һ�����ϲ��ҵ�
                    %�վ���[]Ĭ����double�͵ľ���,����ֱ�����film������
                    obj.Layers=l(i);
                    obj.Layers.z_ini=0;
                else
                    obj.Layers(obj.LayerN)=l(i);
                    obj.Layers(obj.LayerN).z_ini=obj.Layers(obj.LayerN-1).z_ini-obj.Layers(obj.LayerN-1).d;
                end
            end
            
        end
        %-------------------------------------------------------
        %--------------------OPVϵ�к���------------------------
        %------��ֱ�����̫����,���Զ�����s��
        %-------------------------------------------------------
        
        %��ɫ������,��R,T,A
        function obj = RTA_monoE( obj, wl)
            global MinL
            d=zeros(1,obj.LayerN);
            for i=1:obj.LayerN 
                d(i)=obj.Layers(i).d;
            end
            j=wl-MinL+1;
            M_s=eye(2);
            %M_p=eye(2);

            %�����n
            n=zeros(1,obj.LayerN);
            for i=1:obj.LayerN
                    n(i)=obj.Layers(i).nk(j,2)+1i*obj.Layers(i).nk(j,3);
            end
                
            for l=obj.LayerN:-1:1
                    %��ʸ��
                    kz=pi*2*n(l)/wl;
                    %s�����
                    obj.Layers(l).TransM_s{j}=[cos(d(l)*kz),-sin(d(l)*kz)/kz;kz*sin(d(l)*kz),cos(d(l)*kz)];
                    
                    M_s=obj.Layers(l).TransM_s{j}*M_s;
                    %p�����
                    %obj.Layers(l).TransM_p{j}=[cos(d(l)*kz),-n(l)^2*sin(d(l)*kz)/kz;kz*sin(d(l)*kz)/(n(l)*n(l)),cos(d(l)*kz)];  
                    %M_p=obj.Layers(l).TransM_p{j}*M_p;
            end
            kz_fin=pi*2*(obj.surrounding_up(j,2)+1i*obj.surrounding_up(j,3))/wl;
            kz_ini=pi*2*(obj.surrounding_down(j,2)+1i*obj.surrounding_down(j,3))/wl;

            obj.r_s(j)=[kz_ini,1i]*M_s*[1;1i*kz_fin]/([kz_ini,-1i]*M_s*[1;1i*kz_fin]);
            obj.t_s(j)=2*kz_ini/([kz_ini,-1i]*M_s*[1;1i*kz_fin]);

                obj.R(j)=abs(obj.r_s(j))^2;
                %�����������Ҫ��sqrt(nr^s-ni^2)->����Ǵ��
                %n_up=sqrt(obj.surrounding_up(j,2)^2-obj.surrounding_up(j,3)^2);
                %n_down=sqrt(obj.surrounding_down(j,2)^2-obj.surrounding_down(j,3)^2);
                n_up=obj.surrounding_up(j,2)+1i*obj.surrounding_up(j,3);
                n_down=obj.surrounding_down(j,2)+1i*obj.surrounding_down(j,3);
                obj.T(j)=abs(obj.t_s(j))^2*real(n_up/n_down);
                obj.A(j)=1-obj.R(j)-obj.T(j);
                %����ĳЩ����,����n=0���(��nr=ni)���¹�ǿ������ΪNaN����0
                %����,����ʱҪ������������ʶ����ǹ�ǿ������
        end 
        %��������,��R,T,A����
        function obj = RTA_surfL( obj, minwl, maxwl)
            %���������ȫ���ε����գ����䣬͸��ϵ��
            %   obj��device���һ������
            for i=minwl:maxwl
                obj=RTA_monoE(obj,i);
            end
        end
        %��ɫ������,���ģʽ�ֲ�
        function obj= solv_dev(obj,wl)
            %��ø���ĵ糡�ֲ�
            %   monoE�ǵ�ɫ����MonoPlaneWave��һ������
            %   wl��ɫ���Ĳ���
            
            global MaxL MinL
            if wl>MaxL
                display('Wavelength Overflow!')
                return
            end
            j=wl-MinL+1;
            M_s=eye(2);
            %M_p=eye(2);

            %�����n
            n=zeros(obj.LayerN);
            for i=1:obj.LayerN
            	n(i)=obj.Layers(i).nk(j,2)+1i*obj.Layers(i).nk(j,3);
            end
            d=zeros(obj.LayerN);
            for i=1:obj.LayerN 
                d(i)=obj.Layers(i).d;
            end
                    
            for l=obj.LayerN:-1:1
                %��ʸ��
                kz=pi*2*n(l)/wl;
                %s�����
                    obj.Layers(l).TransM_s{j}=[cos(d(l)*kz),-sin(d(l)*kz)/kz;kz*sin(d(l)*kz),cos(d(l)*kz)];
                    
                    M_s=obj.Layers(l).TransM_s{j}*M_s;
                    %p�����
                    %obj.Layers(l).TransM_p{j}=[cos(d(l)*kz),-n(l)^2*sin(d(l)*kz)/kz;kz*sin(d(l)*kz)/(n(l)*n(l)),cos(d(l)*kz)];  
                    %M_p=obj.Layers(l).TransM_p{j}*M_p;

            end
            
            kz_fin=pi*2*(obj.surrounding_up(j,2)+1i*obj.surrounding_up(j,3))/wl;
            kz_ini=pi*2*(obj.surrounding_down(j,2)+1i*obj.surrounding_down(j,3))/wl;

            obj.r_s(j)=[kz_ini,1i]*M_s*[1;1i*kz_fin]/([kz_ini,-1i]*M_s*[1;1i*kz_fin]);
            obj.t_s(j)=2*kz_ini/([kz_ini,-1i]*M_s*[1;1i*kz_fin]); 
            
                obj.R(j)=abs(obj.r_s(j))^2;
                %�����������Ҫ��sqrt(nr^s-ni^2)->����Ǵ��
                %n_up=sqrt(obj.surrounding_up(j,2)^2-obj.surrounding_up(j,3)^2);
                %n_down=sqrt(obj.surrounding_down(j,2)^2-obj.surrounding_down(j,3)^2);
                n_up=obj.surrounding_up(j,2)+1i*obj.surrounding_up(j,3);
                n_down=obj.surrounding_down(j,2)+1i*obj.surrounding_down(j,3);
                obj.T(j)=abs(obj.t_s(j))^2*real(n_up/n_down);
                obj.A(j)=1-obj.R(j)-obj.T(j);
                %����ĳЩ����,����n=0���(��nr=ni)���¹�ǿ������ΪNaN����0
                %����,����ʱҪ������������ʶ����ǹ�ǿ������
            %--------------------------------
            if obj.LayerN==0
                return
            end
            obj.Layers(1).Mod_s{j}=[obj.t_s(j);1i*pi*2*(obj.surrounding_up(j,2)+1i*obj.surrounding_up(j,3))/wl*obj.t_s(j)];
            for l=1:obj.LayerN-1
                obj.Layers(l+1).Mod_s{j}=obj.Layers(l).TransM_s{j}*obj.Layers(l).Mod_s{j};
            end
            
            %�ڼ�������ķ��������ʱ��,ע�����Ҫ���Ǹ���ʸ���鲿���������
            
            
        end
        %��ɫ������,ÿһ��ĵ糡ģʽ
        function obj=EM_destribution(obj,wl)
            obj= solv_dev(obj,wl);
            
            global MinL
            j=wl-MinL+1;
            n=zeros(obj.LayerN);
            for i=1:obj.LayerN
            	n(i)=obj.Layers(i).nk(j,2)+1i*obj.Layers(i).nk(j,3);
            end
            
            if obj.LayerN==0
                display('����Ϊ0')
                return
            end
            sum_d=obj.Layers(obj.LayerN).z_ini-obj.Layers(obj.LayerN).d;
            obj.f_z=zeros(1,-sum_d);
            count_d=1;
            for l=obj.LayerN:-1:1
                kz=pi*2*n(l)/wl;
                for z=obj.Layers(l).z_ini-obj.Layers(l).d+1:obj.Layers(l).z_ini
                    q=(z-obj.Layers(l).z_ini)*kz;
                    obj.f_z(count_d)=[cos(q),sin(q)/kz]*obj.Layers(l).Mod_s{j};
                    count_d=count_d+1;
                end
            end
            
        end
        %��ͼ:��ɫ���������ڵĵ糡ǿ�ȷֲ�
        function plot_EM_destri(obj)
        %   ��ͼ:��ɫ���������ڵĵ糡ǿ�ȷֲ�
        %��EM_destribution֮�����ʹ��
            if obj.LayerN==0
                display('����Ϊ0')
                return
            end
            Mod_E=abs(obj.f_z);
            mini=min(Mod_E);
            maxi=max(Mod_E);
            sum_d=obj.Layers(obj.LayerN).z_ini-obj.Layers(obj.LayerN).d;
            %sum_d=-360;
            axetop=1.5;
            axis([sum_d 0 0 axetop]);
            grid on;
            plot(obj.Layers(obj.LayerN).z_ini-obj.Layers(obj.LayerN).d+1:0,Mod_E);
            hold on;
            axis([sum_d 0 0 axetop]); 
            grid on;
            fix=0.01;%Ϊ�˷�ֹmaxi=mini����,��������ά����ƥ��
            plot(0,mini:(maxi-mini+fix)/100:maxi);
            for l=1:obj.LayerN
                axis([sum_d 0 0 axetop]);
                grid on;
                plot(obj.Layers(l).z_ini-obj.Layers(l).d,mini:(maxi-mini+fix)/100:maxi);
            end
            hold off;
        end
        %��ɫ������,�������հٷֱȵļ���:
        function obj=Absorb_destri_monoE(obj,wl)
            %   ��ɫ����ĳһ�������%%%�ֱ������к����в�ӡ͢���(ò�Ʋ�����)%%%%
            %����EM_destribution
            obj=EM_destribution(obj,wl);
            if obj.LayerN==0
                display('����Ϊ0')
                return
            end
            global MinL
            j=wl-MinL+1;
            
            %����f_z����
            count_fz=1;
            Ab=zeros(1,obj.LayerN);
            for i=obj.LayerN:-1:1
                Ab(i)=0;
                for k=obj.Layers(i).z_ini-obj.Layers(i).d+1:obj.Layers(i).z_ini
                %%%%%%%%%%%%%%%%%%%%%%������
                a_x=obj.f_z(count_fz)*obj.f_z(count_fz)'*obj.Layers(i).nk(j,2)*obj.Layers(i).nk(j,3)/wl;
                Ab(i)=Ab(i)+a_x;
                %%%%%%%%%%%%%%%%%%%%%%%%%
                count_fz=count_fz+1;
                end
            end
            s=sum(Ab);
            for i=1:obj.LayerN
                obj.Layers(i).Absorb(j)=Ab(i)/s;
            end
           
            
            %{
            �������inc,�������trans,���в�for,���в�rev
            switch layerNum                  
                case 1
                    k_inc=2*pi*(obj.Layers(layerNum).nk(j,2)+1i*obj.Layers(layerNum).nk(j,3))/wl;
                    k_trans=2*pi*(obj.surrounding_up(j,2)+1i*obj.surrounding_up(j,3))/wl;
                    [a_inc,b_inc]=AB2ab(obj.Layers(layerNum).Mod_s{j}(1),obj.Layers(layerNum).Mod_s{j}(2),k_inc);
                    a_trans=obj.t_s(j);
                    b_trans=0;
                    n_inc=obj.Layers(layerNum).nk(j,2);
                    n_trans=obj.surrounding_up(j,2);
                otherwise
                    k_inc=2*pi*(obj.Layers(layerNum).nk(j,2)+1i*obj.Layers(layerNum).nk(j,3))/wl;
                    k_trans=2*pi*(obj.Layers(layerNum-1).nk(j,2)+1i*obj.Layers(layerNum-1).nk(j,3))/wl; 
                    [a_inc,b_inc]=AB2ab(obj.Layers(layerNum).Mod_s{j}(1),obj.Layers(layerNum).Mod_s{j}(2),k_inc);
                    [a_trans,b_trans]=AB2ab(obj.Layers(layerNum-1).Mod_s{j}(1),obj.Layers(layerNum-1).Mod_s{j}(2),k_trans);
                    n_inc=obj.Layers(layerNum).nk(j,2);
                    n_trans=obj.Layers(layerNum-1).nk(j,2);
            end

            I_incident_for=n_inc*(a_inc*a_inc');
            I_incident_rev=n_inc*(b_inc*b_inc');            
            I_trans_for=n_trans*(a_trans*a_trans');
            I_trans_rev=n_trans*(b_trans*b_trans');

            A=I_incident_for-I_trans_for+I_trans_rev-I_incident_rev;
            %}
          
        end
        %��ɫ������,���չ�ǿֵ
        function Ab=Absorb_monoL_monoE(obj,l,wl)
            %���չ�ǿֵ
            %��������function obj=Absorb_destri_monoE(obj,wl)
            global MinL
            Ab=obj.Layers(l).Absorb(wl-MinL+1)*obj.A(wl-MinL+1);
        end
        %��������,�������հٷֱȵļ���
        function obj=Absorb_destri(obj,minwl,maxwl)
            for wl=minwl:maxwl
                obj=Absorb_destri_monoE(obj,wl);
            end
        end
        %̫����������,l�����ռ���
        function obj=Absorb_sunspectrum(obj,minwl,maxwl,l)
            global Sunspectrum MinL
            Sun_E=sum(Sunspectrum(:,2));
            obj.Absorb_sun=0;
            obj=Absorb_destri(obj,minwl,maxwl);
            for wl=minwl:maxwl
                j=wl-MinL+1;
                obj.Absorb_sun=obj.Absorb_sun+obj.Layers(l).Absorb(j)*obj.A(j)*Sunspectrum(j,2);
            end
            obj.Absorb_sun=obj.Absorb_sun/Sun_E;
        end
        %��ͼ:̫����������,�����ڹ�ǿE2�ֲ�
        function plot_EM_destri_sunsp(obj,minwl,maxwl)
            if obj.LayerN==0
                display('����Ϊ0')
                return
            end
            
            global Sunspectrum MinL MaxL
            %Sun_E=sum(Sunspectrum(:,2));
            sum_d=obj.Layers(obj.LayerN).z_ini-obj.Layers(obj.LayerN).d;
            %E(wl,d)��¼��ɫ��������������ĳ���괦�ĵ糡ǿ��
            E=zeros(MaxL-MinL+1,-sum_d);
            for wl=minwl:maxwl
                obj=EM_destribution(obj,wl);
                E(wl-MinL+1,:)=obj.f_z.*conj(obj.f_z);
            end
            E_wl=zeros(1,-sum_d);
            for x=1:-sum_d
                for wl=minwl:maxwl
                    j=wl-MinL+1;
                    E_wl(x)=E_wl(x)+E(j,x)*Sunspectrum(j);
                end
            end
            
            mini=min(E_wl);
            maxi=max(E_wl);
            
            grid on;
            plot(obj.Layers(obj.LayerN).z_ini-obj.Layers(obj.LayerN).d+1:0,E_wl);
            hold on;
            grid on;
            fix=0.01;%Ϊ�˷�ֹmaxi=mini����,��������ά����ƥ��
            plot(0,mini:(maxi-mini+fix)/100:maxi);
            for l=1:obj.LayerN
                grid on;
                plot(obj.Layers(l).z_ini-obj.Layers(l).d,mini:(maxi-mini+fix)/100:maxi);
            end
            hold off;
        end
        
        
	end
end

