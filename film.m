classdef film
    %����Ĥ����
    %   Detailed explanation goes here
    properties
        %-----------��������----------
        d;%���/nm
        nk;%ɫɢ��ϵ(����������������-�����Ĺ�ϵ)
        name;%��������
        EM; %��Ų� mono poly
        %-------���������ز���----------
        TransM_s;%s���������
        TransM_p;%p��
        Mod_s;%s��ϵ��,������[A;B]
        Mod_p;%p
        Absorb;  %�ò�Ը����������հٷֱ�size=MaxL-MinL+1
        z_ini; %�ò���device�е���ʼ����
    end
    
    methods
        %���캯��
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

            %-------��ʼ���������----------
            global MaxL MinL

            %����������cell����,ÿ��Ԫ��TransM_s{k}��һ��2*2����
            obj.TransM_s=cell(1,MaxL-MinL+1);
            obj.TransM_p=cell(1,MaxL-MinL+1);

            %����������cell����,ÿ��Ԫ����һ��1*2����
            %����A,B.Mod_s{k}��1*2�ľ���;Mod_s{k}(1)��A;Mod_s{k}(2)��B
            obj.Mod_s=cell(1,MaxL-MinL+1);%����������cell����,ÿ��Ԫ����һ��1*2����
            obj.Mod_p=cell(1,MaxL-MinL+1);
            
            %����
            obj.Absorb=zeros(1,MaxL-MinL+1);
            
            %��Ų���
            

        end
    end

end

