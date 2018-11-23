
%-------------------------初始数据输入-----------------------------
%	长度单位：nm
%	假设：光垂直入射:kz=k-----
%-----------层数------------
LayerN=4;
%--------每层厚度-----------
load 'd.txt';%各层厚度,包括电极
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
P3HT_PCBM=load( 'P3HT-PCBM.txt');
Al=load ('Al.txt');

myMaterial=zeros(601,3);
myMaterial(:,1)=MinL:MaxL;
myMaterial(:,2)=1;
myMaterial(:,3)=0;
%-----------输入光谱-------
global Sunspectrum;
load 'Sunspectrum.txt';%太阳光光谱
Sun_E=sum(Sunspectrum(:,2));%单位面积太阳光光强


myDev_test=device;
myDev_test.surrounding_up=1+0i;
myDev_test.surrounding_down=1+0i;

myFilm_test=film(120,Al,'Al');
myFilm_test(2)=film(100,myMaterial,'myMaterial');
myFilm_test(3)=film(0,Ag,'Ag');
myDev_test=AddLayer(myDev_test,myFilm_test);
myDev_test=RTA_surfL(myDev_test);


figure
plot(MinL:MaxL,100*myDev_test.R)
xlabel('wavelength / nm'); % x轴注解
ylabel('%'); 
title('R'); % 图形标题

grid on; % 显示格线

figure
plot(MinL:MaxL,100*myDev_test.T)
xlabel('wavelength / nm'); % x轴注解
ylabel('%'); 
title('T'); % 图形标题

grid on; % 显示格线

figure
plot(MinL:MaxL,100*myDev_test.A)
xlabel('wavelength / nm'); % x轴注解
ylabel('%'); 
title('A'); % 图形标题

grid on; % 显示格线

figure
plot(MinL:MaxL,100*myDev_test.R,'-b',MinL:MaxL,100*myDev_test.T,'--r',MinL:MaxL,100*myDev_test.A,'-.k');
xlabel('wavelength / nm'); % x轴注解
ylabel('%'); 
title('RTA'); % 图形标题
legend('R','T','A');
grid on; % 显示格线

