%-------------------------初始数据输入-----------------------------
%	长度单位：nm
%	假设：光垂直入射:kz=k-----
%-----------层数------------
LayerN=4;
%--------每层厚度-----------
load 'd.txt';%各层厚度,包括电极
%----------材料色散曲线----------
global ITO Ag P3HT_PCBM Al;
ITO=load('ITO.txt');
Ag=load( 'Ag.txt');
P3HT_PCBM=load( 'P3HT-PCBM.txt');
Al=load ('Al.txt');
%-----------输入光谱-------
global Sunspectrum;
load 'Sunspectrum.txt';%太阳光光谱
load 'Sun_E.mat'

%---------波长范围-----------
%取300nm-900nm
global wavelength MaxL MinL;
MaxL=900;
MinL=300;
wavelength=MinL:MaxL;
%   反射、透射、吸收率
R=wavelength;
T=wavelength;
A=wavelength;

%--------微腔厚度上下界-------
MaxD=1000;
MinD=1;

%----------有机层在微腔中的位置-------
DiploePos=0.5;%Position of Dipole (0~1)

%-------------------------数据输入完毕-----------------------------------

%-------------------------对象初始化-------------------------------------
%吸收矩阵，在特定波长和腔长下的吸收率
Absorb=zeros(MaxD-MinD+1,MaxL-MinL+1);
Absorb_OrgOnly=zeros(MaxD-MinD+1,MaxL-MinL+1);
Absorb_InorgOnly=zeros(MaxD-MinD+1,MaxL-MinL+1);
%器件中主要吸收层是Ag和有机层

%构造我的器件:一号器件
%6层：依次为：阴极，ITO腔，有机层，ITO腔，反射Ag层，阳极
myFilm=film(d(1),Al,'Al');
myFilm(2)=film(d(2),ITO,'ITO');
myFilm(3)=film(d(3),P3HT_PCBM,'P3HT_PCBM');
myFilm(4)=film(d(4),ITO,'ITO');
myFilm(5)=film(d(5),Ag,'Ag');
myFilm(6)=film(d(6),ITO,'ITO');
myDev=device;
myDev=AddLayer(myDev,myFilm);

%两个ITO层厚度和一定
dITO=1000;
%二号器件：假设只有Org层吸收，其它层不吸收，计算Org层吸收
myDev(2)=myDev;
myDev(2).Layers(1).nk(:,3)=zeros(MaxL-MinL+1,1);%Al的nk曲线虚部为零
myDev(2).Layers(2).nk(:,3)=zeros(MaxL-MinL+1,1);%ITO(1)的nk曲线虚部为零
myDev(2).Layers(4).nk(:,3)=zeros(MaxL-MinL+1,1);%ITO(2)的nk曲线虚部为零
myDev(2).Layers(5).nk(:,3)=zeros(MaxL-MinL+1,1);%Ag的nk曲线虚部为零
myDev(2).Layers(6).nk(:,3)=zeros(MaxL-MinL+1,1);%ITO(3)的nk曲线虚部为零

for k=MinD:MaxD%遍历微腔厚度
   myDev(2).Layers(4).d=k;
   myDev(2).Layers(2).d=dITO-k;
   [R,T,A]=RTA_surfL(myDev(2),wavelength);
    
    Absorb_OrgOnly(k-MinD+1,:)=A;
    
end

%三号器件：假设Org层不吸收，计算其它层吸收
myDev(3)=myDev(1);
myDev(3).Layers(3).nk(:,3)=zeros(MaxL-MinL+1,1);%Org的nk曲线虚部为零
for k=MinD:MaxD%遍历微腔厚度
    myDev(3).Layers(4).d=k;
    myDev(3).Layers(2).d=dITO-k;
   [R,T,A]=RTA_surfL(myDev(3),wavelength);
    
    Absorb_InorgOnly(k-MinD+1,:)=A;
    
end

%求有机物吸收谱,Ag、Al和有机层都有吸收


for k=MinD:MaxD%遍历微腔厚度
    myDev(1).Layers(4).d=k;
    myDev(1).Layers(2).d=dITO-k;
   [R,T,A]=RTA_surfL(myDev(1),wavelength);
    
    Absorb(k-MinD+1,:)=A;
    
end
    
%吸收率等    
%plot(wavelength,R)
%plot(wavelength,T)
%plot(wavelength,A)

%吸收光强等
%plot(wavelength,R.*Sunspectrum(:,2).')
%plot(wavelength,A.*Sunspectrum(:,2).')

%遍历微腔厚度

r=Absorb_OrgOnly./(Absorb_InorgOnly+Absorb_OrgOnly);
Org_A=Absorb.*r;
%{
for i=MinD:MaxD%修正超过1的部分，强制为1
    for j=1:MaxL-MinL+1
        if Org_A(i,j)>1
            Org_A(i,j)=1;
        end
        if Org_A(i,j)<0
            Org_A(i,j)=0;
        end
    end
end
%}
Ab_E=zeros(1,MaxD-MinD+1);
for i=MinD:MaxD
    temp=Org_A(i,:).*Sunspectrum(:,2).';
    Ab_E(i)=sum(temp);

end

figure
surf(Org_A)
shading flat

figure
plot(MinD:MaxD,Ab_E/Sun_E)




