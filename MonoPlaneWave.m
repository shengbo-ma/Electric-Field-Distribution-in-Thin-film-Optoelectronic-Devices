%global miu0 epsilong0 c
classdef MonoPlaneWave
    %电磁波类
    %   处于介质中的电磁波
    %   
    %???
    properties
        %---------真空中的量-----------
        E_xyz;%电场强度矢量
        k0_xyz;%波矢
        k0;%波矢大小
        k_direc;%波矢方向，注意,是介质中的复波矢
        w;%圆频率
        wl0;%波长   
        %--------介质中的量---------
        n;%复折射率
        k;%复波矢的大小

        
        %-------其他电磁参量---------
        H;%磁场强度矢量
        D;%电位移矢量
        B;%磁感应强度矢量
        S;%玻印亭矢量
        %----偏振相关---
        Es_A;%s波复振幅
        Ep_A;%p波复振幅 

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

