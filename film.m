classdef film
    %单层膜的类
    %   Detailed explanation goes here
    properties
        %-----------基本参数----------
        d;%厚度/nm
        nk;%色散关系(输入数据是折射率-波长的关系)
        name;%材料名称
        EM; %电磁波 mono poly
        %-------传输矩阵相关参数----------
        TransM_s;%s波传输矩阵
        TransM_p;%p波
        Mod_s;%s波系数,列向量[A;B]
        Mod_p;%p
        Absorb;  %该层对各波长的吸收百分比size=MaxL-MinL+1
        z_ini; %该层在device中的起始坐标
    end
    
    methods
        %构造函数
        function obj=film(d,nk,name)
            if nargin==3
                obj.d=d;
                obj.nk=nk;
                obj.name=name;
            end
            if nargin==0
                obj.d=0;
                obj.nk=[];
                obj.name='';
            end

            %-------初始化传输矩阵----------
            global MaxL MinL

            %遍历波长的cell矩阵,每个元素TransM_s{k}是一个2*2矩阵
            obj.TransM_s=cell(1,MaxL-MinL+1);
            obj.TransM_p=cell(1,MaxL-MinL+1);

            %遍历波长的cell矩阵,每个元素是一个1*2矩阵
            %包括A,B.Mod_s{k}是1*2的矩阵;Mod_s{k}(1)是A;Mod_s{k}(2)是B
            obj.Mod_s=cell(1,MaxL-MinL+1);%遍历波长的cell矩阵,每个元素是一个1*2矩阵
            obj.Mod_p=cell(1,MaxL-MinL+1);
            
            %吸收
            obj.Absorb=zeros(1,MaxL-MinL+1);
            
            %电磁波谱
            

        end
    end

end

