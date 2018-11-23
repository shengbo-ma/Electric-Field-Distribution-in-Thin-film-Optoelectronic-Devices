clear
%-------------------------��ʼ��������-----------------------------
%	���ȵ�λ��nm
%	���裺�ⴹֱ����:kz=k-----
%-----------����------------
%LayerN=4;
%--------ÿ����-----------
load 'd.txt';%������,�����缫
%---------������Χ-----------
%ȡ300nm-900nm
global wavelength MaxL MinL;
MaxL=900;
MinL=300;
wavelength=MinL:MaxL;
%----------����ɫɢ����----------
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

myMaterial3=zeros(601,3);
myMaterial3(:,1)=MinL:MaxL;
myMaterial3(:,2)=2;
myMaterial3(:,3)=0;

mySur1=zeros(601,3);
mySur1(:,1)=MinL:MaxL;
mySur1(:,2)=100000;
mySur1(:,3)=0;
%-----------�������-------
global Sunspectrum;
load 'Sunspectrum.txt';%̫�������
Sun_E=sum(Sunspectrum(:,2));%��λ���̫�����ǿ

%----������LayerForSurf��ĺ��---
LayerForSurf=2;
%--------���������½�-------
MaxD=533;
MinD=1;


myDev_test=device;


myFilm_test=film(57,myMaterial3,'myMaterial3');
myFilm_test(2)=film(0,myMaterial,'myMaterial');
%myFilm_test(3)=film(333,myMaterial,'myMaterial');


myDev_test=AddLayer(myDev_test,myFilm_test);

R=zeros(1,MaxD-MinD+1);
T=zeros(1,MaxD-MinD+1);
A=zeros(1,MaxD-MinD+1);
%��ĳһ����ɫ����
choosenwl=500;
figure
for k=MinD:MaxD
 
    %------------- ��������LayerForSurf����---------------
    myFilm_test(LayerForSurf).d=k;

    myDev_test=device(myFilm_test);
    myDev_test.surrounding_up=mySur1;
    myDev_test.surrounding_down=myMaterial;
    
	myDev_test=RTA_monoE(myDev_test,choosenwl);
    R(k)=myDev_test.R(choosenwl-MinL+1);
    T(k)=myDev_test.T(choosenwl-MinL+1);
    A(k)=myDev_test.A(choosenwl-MinL+1);

    myDev_test=EM_destribution(myDev_test,choosenwl);
    plot_EM_destri(myDev_test);
    pause(0.01);
end


figure
plot(MinD:MaxD,100*R)
xlabel('length of microcavity / nm'); % x��ע��
ylabel('power Absorbing efficiency(%)'); % y��ע�� PCE=power converting efficiency
title('R'); % ͼ�α���
legend(strcat('Layer',num2str(LayerForSurf))); % ͼ��ע��
grid on; % ��ʾ����

figure
plot(MinD:MaxD,100*T)
xlabel('length of microcavity / nm'); % x��ע��
ylabel('power Absorbing efficiency(%)'); % y��ע�� PCE=power converting efficiency
title('T'); % ͼ�α���
legend(strcat('Layer',num2str(LayerForSurf))); % ͼ��ע��
grid on; % ��ʾ����

figure
plot(MinD:MaxD,100*A)
xlabel('length of microcavity / nm'); % x��ע��
ylabel('power Absorbing efficiency(%)'); % y��ע�� PCE=power converting efficiency
title('A'); % ͼ�α���
legend(strcat('Layer',num2str(LayerForSurf))); % ͼ��ע��
grid on; % ��ʾ����

figure
plot(MinD:MaxD,100*R,'-b',MinD:MaxD,100*T,'--r',MinD:MaxD,100*A,'-.k');
xlabel('wavelength / nm'); % x��ע��
ylabel('%'); 
title('RTA'); % ͼ�α���
legend('R','T','A')
grid on; % ��ʾ����


