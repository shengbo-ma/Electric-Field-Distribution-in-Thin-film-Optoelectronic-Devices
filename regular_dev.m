%比较标准器件
%微腔器件和Heeger器件,找出spacer最佳厚度配置

clear
%-------------------------初始数据输入-----------------------------
%	长度单位：nm
%	假设：光垂直入射:kz=k-----

%---------波长范围-----------
%取300nm-900nm
global wavelength MaxL MinL;
MaxL=900;
MinL=300;
wavelength=MinL:MaxL;
%----------材料色散曲线----------
global ITO Ag P3HT_PCBM Al;
ITO=load('ITO.txt');
Ag=load( 'Ag.txt');
Au=load( 'Au.txt');
P3HT_PCBM=load( 'P3HT-PCBM.txt');
Al=load ('Al.txt');
PEDOT=load ('PEDOT_BaytronP_AL4083.txt');

myMaterial=zeros(601,3);
myMaterial(:,1)=MinL:MaxL;
myMaterial(:,2)=1;
myMaterial(:,3)=0;

myMaterial2=zeros(601,3);
myMaterial2(:,1)=MinL:MaxL;
myMaterial2(:,2)=1;
myMaterial2(:,3)=P3HT_PCBM(:,3);

mySur1=zeros(601,3);
mySur1(:,1)=MinL:MaxL;
mySur1(:,2)=100000;
mySur1(:,3)=0;
%-----------输入光谱-------
global Sunspectrum;
load 'Sunspectrum.txt';%太阳光光谱
Sun_E=sum(Sunspectrum(:,2));%单位面积太阳光光强

%--------每层厚度-----------
load 'd.txt';%各层厚度,包括电极
%-----------------------------

%标准器件
reg_d=[120,40,10,100];%没考虑LiF层

reg_film=film(reg_d(1),Al,'Al');
reg_film(2)=film(reg_d(2),P3HT_PCBM,'P3HT_PCBM');
reg_film(3)=film(reg_d(3),PEDOT,'PEDOT');
reg_film(4)=film(reg_d(4),ITO,'ITO');

reg_dev=device(reg_film);

%看某一个单色波长
chosenwl=500;
%看某一波段
minwl=300;
maxwl=900;

reg_dev=RTA_surfL(reg_dev, minwl, maxwl);
%}
%{
figure
plot(wavelength,100*reg_dev.R)
xlabel('wavelength / nm'); % x轴注解
ylabel('R(%)'); % y轴注解 PCE=power converting efficiency
title('反射率'); % 图形标题
grid on; % 显示格线

figure
plot(wavelength,100*reg_dev.T)
xlabel('wavelength / nm'); % x轴注解
ylabel('T(%)'); % y轴注解 PCE=power converting efficiency
title('透射率'); % 图形标题
grid on; % 显示格线

figure
plot(wavelength,100*reg_dev.A)
xlabel('wavelength / nm'); % x轴注解
ylabel('A(%)'); % y轴注解 PCE=power converting efficiency
title('吸收率'); % 图形标题
grid on; % 显示格线
%}

figure
plot(wavelength,100*reg_dev.R,'-b',wavelength,100*reg_dev.T,'--r',wavelength,100*reg_dev.A,'-.k');
xlabel('wavelength / nm'); % x轴注解
ylabel('%'); 
title('RTA'); % 图形标题
legend('R','T','A')
grid on; % 显示格线
%}
%{
reg_dev=EM_destribution(reg_dev,chosenwl);
plot_EM_destri(reg_dev);
%}
OrgNo=2;
reg_dev=Absorb_sunspectrum(reg_dev,minwl,maxwl,OrgNo);
reg_dev.Absorb_sun
Ab=zeros(1,MaxL-MinL+1);
for wl=minwl:maxwl
Ab(wl-MinL+1)=Absorb_monoL_monoE(reg_dev,2,wl);
end
plot(minwl:maxwl,Ab)
%{
figure
plot(wavelength,100*reg_dev.Layers(OrgNo).Absorb,'-b',wavelength,100*reg_dev.A,'--r',wavelength,100*Ab,'-.k');
xlabel('wavelength / nm'); % x轴注解
ylabel('%'); 
title('吸收百分比'); % 图形标题
legend('OrgLayer','dev','total')
grid on; % 显示格线

reg_dev=Absorb_sunspectrum(reg_dev,minwl,maxwl,OrgNo);
reg_dev.Absorb_sun

figure
plot_EM_destri_sunsp(reg_dev,minwl,maxwl);
%}