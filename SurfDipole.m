clear
%-------------------------初始数据输入-----------------------------
%	长度单位：nm
%	假设：光垂直入射:kz=k-----
%-----------层数------------
%LayerN=4;
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

%----遍历第LayerForSurf层的厚度---
LayerForSurf=1;
%--------微腔spacer总厚度-------
D=500;


myDev_test=device;


myFilm_test=film(0,myMaterial,'myMaterial');
myFilm_test(2)=film(30,myMaterial2,'myMaterial2');
myFilm_test(3)=film(0,myMaterial,'myMaterial');


myDev_test=AddLayer(myDev_test,myFilm_test);

%看某一个单色波长
choosenwl=500;
%左端距离
x=0;

R=zeros(1,D+1);
T=zeros(1,D+1);
A=zeros(1,D+1);

figure

for x=0:1:D

    %------------- 器件遍历LayerForSurf层厚度---------------
    myFilm_test(1).d=x;
    myFilm_test(3).d=D-x;
    myDev_test=device(myFilm_test);
    myDev_test.surrounding_up=mySur1;
    myDev_test.surrounding_down=myMaterial;
    
	myDev_test=RTA_monoE(myDev_test,choosenwl);
    R(x+1)=myDev_test.R(choosenwl-MinL+1);
    T(x+1)=myDev_test.T(choosenwl-MinL+1);
    A(x+1)=myDev_test.A(choosenwl-MinL+1);
    
    myDev_test=EM_destribution(myDev_test,choosenwl);
    plot_EM_destri(myDev_test);
    pause(0.01);
end

figure
plot(0:D,100*R)
xlabel('length of microcavity / nm'); % x轴注解
ylabel('power Absorbing efficiency(%)'); % y轴注解 PCE=power converting efficiency
title('R'); % 图形标题
legend(strcat('Layer',num2str(LayerForSurf))); % 图形注解
grid on; % 显示格线

figure
plot(0:D,100*T)
xlabel('length of microcavity / nm'); % x轴注解
ylabel('power Absorbing efficiency(%)'); % y轴注解 PCE=power converting efficiency
title('T'); % 图形标题
legend(strcat('Layer',num2str(LayerForSurf))); % 图形注解
grid on; % 显示格线

figure
plot(0:D,100*A)
xlabel('length of microcavity / nm'); % x轴注解
ylabel('power Absorbing efficiency(%)'); % y轴注解 PCE=power converting efficiency
title('A'); % 图形标题
legend(strcat('Layer',num2str(LayerForSurf))); % 图形注解
grid on; % 显示格线

figure
plot(0:D,100*R,'-b',0:D,100*T,'--r',0:D,100*A,'-.k');
xlabel('wavelength / nm'); % x轴注解
ylabel('%'); 
title('RTA'); % 图形标题
legend('R','T','A')
grid on; % 显示格线



