classdef device
    %器件类，由多层膜组成，主要操作film数组
    %   光从器件下向上垂直入射，层数编号从上至下增大
    %   有上下两个边界条件，默认为真空
    properties
        LayerN;     %层数（包括电极）
        surrounding_up;%折射率上边界条件nk(例如真空)
        surrounding_down;%下边界条件nk(例如真空)
        Layers;     %film数组
        Absorb_sun; %太阳光吸收百分比
        %-------------记录中间值----------
        r_s;          %s波复振幅反射率
        t_s;          %s波复振幅透射率
        r_p;          %p波复振幅反射率
        t_p;          %p波复振幅透射率
        R;          %反射谱:大小是1*wavelength的矩阵
        T;          %透射谱:大小是1*wavelength的矩阵
        A;          %吸收谱:大小是1*wavelength的矩阵
        f_z;        %相对值,顺光向记录数据
        I_z;        %相对值,顺光向记录数据
        %-----------------------------------------
        err;        %模拟误差

    end
    
	methods
        %---------------------------------------
        %------------器件构造函数--------------
        %------------------------------------
        function obj=device(l)
            %构造函数
            global MaxL MinL            
            obj.LayerN=0;
            obj.surrounding_up=zeros(MaxL-MinL+1,3);
            obj.surrounding_up(:,1)=MinL:MaxL;
            obj.surrounding_up(:,2)=1.0;%真空环境
            obj.surrounding_up(:,3)=0;%真空环境
            obj.surrounding_down=zeros(MaxL-MinL+1,3);
            obj.surrounding_down(:,1)=MinL:MaxL;
            obj.surrounding_down(:,2)=1.5;%glass环境
            obj.surrounding_down(:,3)=0;%glass环境
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
            %加入一组新的层,l是film类的一个数组
            %阴极是第一层
            s=size(l);
            n=s(2);%l的维数
            for i=1:n
                obj.LayerN=obj.LayerN+1;
                if obj.LayerN==1%%%%%这里很容易出错！一个晚上才找到
                    %空矩阵[]默认是double型的矩阵,不能直接添加film型数据
                    obj.Layers=l(i);
                    obj.Layers.z_ini=0;
                else
                    obj.Layers(obj.LayerN)=l(i);
                    obj.Layers(obj.LayerN).z_ini=obj.Layers(obj.LayerN-1).z_ini-obj.Layers(obj.LayerN-1).d;
                end
            end
            
        end
        %-------------------------------------------------------
        %--------------------OPV系列函数------------------------
        %------垂直入射的太阳光,可以都看成s波
        %-------------------------------------------------------
        
        %单色波入射,求R,T,A
        function obj = RTA_monoE( obj, wl)
            global MinL
            d=zeros(1,obj.LayerN);
            for i=1:obj.LayerN 
                d(i)=obj.Layers(i).d;
            end
            j=wl-MinL+1;
            M_s=eye(2);
            %M_p=eye(2);

            %各层的n
            n=zeros(1,obj.LayerN);
            for i=1:obj.LayerN
                    n(i)=obj.Layers(i).nk(j,2)+1i*obj.Layers(i).nk(j,3);
            end
                
            for l=obj.LayerN:-1:1
                    %波矢量
                    kz=pi*2*n(l)/wl;
                    %s光矩阵
                    obj.Layers(l).TransM_s{j}=[cos(d(l)*kz),-sin(d(l)*kz)/kz;kz*sin(d(l)*kz),cos(d(l)*kz)];
                    
                    M_s=obj.Layers(l).TransM_s{j}*M_s;
                    %p光矩阵
                    %obj.Layers(l).TransM_p{j}=[cos(d(l)*kz),-n(l)^2*sin(d(l)*kz)/kz;kz*sin(d(l)*kz)/(n(l)*n(l)),cos(d(l)*kz)];  
                    %M_p=obj.Layers(l).TransM_p{j}*M_p;
            end
            kz_fin=pi*2*(obj.surrounding_up(j,2)+1i*obj.surrounding_up(j,3))/wl;
            kz_ini=pi*2*(obj.surrounding_down(j,2)+1i*obj.surrounding_down(j,3))/wl;

            obj.r_s(j)=[kz_ini,1i]*M_s*[1;1i*kz_fin]/([kz_ini,-1i]*M_s*[1;1i*kz_fin]);
            obj.t_s(j)=2*kz_ini/([kz_ini,-1i]*M_s*[1;1i*kz_fin]);

                obj.R(j)=abs(obj.r_s(j))^2;
                %这里的折射率要用sqrt(nr^s-ni^2)->这个是错的
                %n_up=sqrt(obj.surrounding_up(j,2)^2-obj.surrounding_up(j,3)^2);
                %n_down=sqrt(obj.surrounding_down(j,2)^2-obj.surrounding_down(j,3)^2);
                n_up=obj.surrounding_up(j,2)+1i*obj.surrounding_up(j,3);
                n_down=obj.surrounding_down(j,2)+1i*obj.surrounding_down(j,3);
                obj.T(j)=abs(obj.t_s(j))^2*real(n_up/n_down);
                obj.A(j)=1-obj.R(j)-obj.T(j);
                %对于某些金属,会有n=0情况(当nr=ni)导致光强反射率为NaN或者0
                %所以,计算时要带用振幅反射率而不是光强反射率
        end 
        %光谱入射,求R,T,A光谱
        function obj = RTA_surfL( obj, minwl, maxwl)
            %输出器件对全波段的吸收，反射，透射系数
            %   obj是device类的一个对象
            for i=minwl:maxwl
                obj=RTA_monoE(obj,i);
            end
        end
        %单色波入射,求解模式分布
        function obj= solv_dev(obj,wl)
            %解得各层的电场分布
            %   monoE是单色波，MonoPlaneWave的一个对象
            %   wl单色波的波长
            
            global MaxL MinL
            if wl>MaxL
                display('Wavelength Overflow!')
                return
            end
            j=wl-MinL+1;
            M_s=eye(2);
            %M_p=eye(2);

            %各层的n
            n=zeros(obj.LayerN);
            for i=1:obj.LayerN
            	n(i)=obj.Layers(i).nk(j,2)+1i*obj.Layers(i).nk(j,3);
            end
            d=zeros(obj.LayerN);
            for i=1:obj.LayerN 
                d(i)=obj.Layers(i).d;
            end
                    
            for l=obj.LayerN:-1:1
                %波矢量
                kz=pi*2*n(l)/wl;
                %s光矩阵
                    obj.Layers(l).TransM_s{j}=[cos(d(l)*kz),-sin(d(l)*kz)/kz;kz*sin(d(l)*kz),cos(d(l)*kz)];
                    
                    M_s=obj.Layers(l).TransM_s{j}*M_s;
                    %p光矩阵
                    %obj.Layers(l).TransM_p{j}=[cos(d(l)*kz),-n(l)^2*sin(d(l)*kz)/kz;kz*sin(d(l)*kz)/(n(l)*n(l)),cos(d(l)*kz)];  
                    %M_p=obj.Layers(l).TransM_p{j}*M_p;

            end
            
            kz_fin=pi*2*(obj.surrounding_up(j,2)+1i*obj.surrounding_up(j,3))/wl;
            kz_ini=pi*2*(obj.surrounding_down(j,2)+1i*obj.surrounding_down(j,3))/wl;

            obj.r_s(j)=[kz_ini,1i]*M_s*[1;1i*kz_fin]/([kz_ini,-1i]*M_s*[1;1i*kz_fin]);
            obj.t_s(j)=2*kz_ini/([kz_ini,-1i]*M_s*[1;1i*kz_fin]); 
            
                obj.R(j)=abs(obj.r_s(j))^2;
                %这里的折射率要用sqrt(nr^s-ni^2)->这个是错的
                %n_up=sqrt(obj.surrounding_up(j,2)^2-obj.surrounding_up(j,3)^2);
                %n_down=sqrt(obj.surrounding_down(j,2)^2-obj.surrounding_down(j,3)^2);
                n_up=obj.surrounding_up(j,2)+1i*obj.surrounding_up(j,3);
                n_down=obj.surrounding_down(j,2)+1i*obj.surrounding_down(j,3);
                obj.T(j)=abs(obj.t_s(j))^2*real(n_up/n_down);
                obj.A(j)=1-obj.R(j)-obj.T(j);
                %对于某些金属,会有n=0情况(当nr=ni)导致光强反射率为NaN或者0
                %所以,计算时要带用振幅反射率而不是光强反射率
            %--------------------------------
            if obj.LayerN==0
                return
            end
            obj.Layers(1).Mod_s{j}=[obj.t_s(j);1i*pi*2*(obj.surrounding_up(j,2)+1i*obj.surrounding_up(j,3))/wl*obj.t_s(j)];
            for l=1:obj.LayerN-1
                obj.Layers(l+1).Mod_s{j}=obj.Layers(l).TransM_s{j}*obj.Layers(l).Mod_s{j};
            end
            
            %在计算金属的反射折射的时候,注意振幅要考虑复波矢的虚部和振幅两者
            
            
        end
        %单色波入射,每一点的电场模式
        function obj=EM_destribution(obj,wl)
            obj= solv_dev(obj,wl);
            
            global MinL
            j=wl-MinL+1;
            n=zeros(obj.LayerN);
            for i=1:obj.LayerN
            	n(i)=obj.Layers(i).nk(j,2)+1i*obj.Layers(i).nk(j,3);
            end
            
            if obj.LayerN==0
                display('层数为0')
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
        %作图:单色波在器件内的电场强度分布
        function plot_EM_destri(obj)
        %   作图:单色波在器件内的电场强度分布
        %在EM_destribution之后才能使用
            if obj.LayerN==0
                display('层数为0')
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
            fix=0.01;%为了防止maxi=mini出现,导致向量维数不匹配
            plot(0,mini:(maxi-mini+fix)/100:maxi);
            for l=1:obj.LayerN
                axis([sum_d 0 0 axetop]);
                grid on;
                plot(obj.Layers(l).z_ini-obj.Layers(l).d,mini:(maxi-mini+fix)/100:maxi);
            end
            hold off;
        end
        %单色波入射,各层吸收百分比的计算:
        function obj=Absorb_destri_monoE(obj,wl)
            %   单色波在某一层的吸收%%%分别用正行和逆行波印廷算吧(貌似不可行)%%%%
            %基于EM_destribution
            obj=EM_destribution(obj,wl);
            if obj.LayerN==0
                display('层数为0')
                return
            end
            global MinL
            j=wl-MinL+1;
            
            %计算f_z坐标
            count_fz=1;
            Ab=zeros(1,obj.LayerN);
            for i=obj.LayerN:-1:1
                Ab(i)=0;
                for k=obj.Layers(i).z_ini-obj.Layers(i).d+1:obj.Layers(i).z_ini
                %%%%%%%%%%%%%%%%%%%%%%待完善
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
            入射界面inc,出射界面trans,正行波for,逆行波rev
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
        %单色波入射,吸收光强值
        function Ab=Absorb_monoL_monoE(obj,l,wl)
            %吸收光强值
            %需先运行function obj=Absorb_destri_monoE(obj,wl)
            global MinL
            Ab=obj.Layers(l).Absorb(wl-MinL+1)*obj.A(wl-MinL+1);
        end
        %光谱入射,各层吸收百分比的计算
        function obj=Absorb_destri(obj,minwl,maxwl)
            for wl=minwl:maxwl
                obj=Absorb_destri_monoE(obj,wl);
            end
        end
        %太阳光谱入射,l层吸收计算
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
        %作图:太阳光谱入射,器件内光强E2分布
        function plot_EM_destri_sunsp(obj,minwl,maxwl)
            if obj.LayerN==0
                display('层数为0')
                return
            end
            
            global Sunspectrum MinL MaxL
            %Sun_E=sum(Sunspectrum(:,2));
            sum_d=obj.Layers(obj.LayerN).z_ini-obj.Layers(obj.LayerN).d;
            %E(wl,d)记录单色波入射在器件内某坐标处的电场强度
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
            fix=0.01;%为了防止maxi=mini出现,导致向量维数不匹配
            plot(0,mini:(maxi-mini+fix)/100:maxi);
            for l=1:obj.LayerN
                grid on;
                plot(obj.Layers(l).z_ini-obj.Layers(l).d,mini:(maxi-mini+fix)/100:maxi);
            end
            hold off;
        end
        
        
	end
end

