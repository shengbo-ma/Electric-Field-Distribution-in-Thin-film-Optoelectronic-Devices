%global miu0 epsilong0 c
classdef MonoPlaneWave
    %��Ų���
    %   ���ڽ����еĵ�Ų�
    %   
    %???
    properties
        %---------����е���-----------
        E_xyz;%�糡ǿ��ʸ��
        k0_xyz;%��ʸ
        k0;%��ʸ��С
        k_direc;%��ʸ����ע��,�ǽ����еĸ���ʸ
        w;%ԲƵ��
        wl0;%����   
        %--------�����е���---------
        n;%��������
        k;%����ʸ�Ĵ�С

        
        %-------������Ų���---------
        H;%�ų�ǿ��ʸ��
        D;%��λ��ʸ��
        B;%�Ÿ�Ӧǿ��ʸ��
        S;%��ӡͤʸ��
        %----ƫ�����---
        Es_A;%s�������
        Ep_A;%p������� 

    end
    
    methods
        function obj=MonoPlaneWave(E_xyz,k0_xyz,n)
            global miu0 epsilong0 c
            if nargin==0
                obj.E_xyz=[1,0,0];
                obj.n=1;
                obj.k0_xyz=[0,0,1];
            end
            if nargin==3
                obj.E_xyz=E_xyz;
                obj.n=n;
                obj.k0_xyz=k0_xyz;
            end
            
            obj.k0=sqrt(obj.k0_xyz*obj.k0_xyz.');
            obj.wl0=2*pi/obj.k0;
            obj.w=obj.k0*c;
            obj.k_direc=obj.k0_xyz/obj.k0;
            obj.k=obj.k0*obj.n;
        end
    end
    
end

