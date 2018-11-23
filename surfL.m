
%-------------------------��ʼ��������-----------------------------
%	���ȵ�λ��nm
%	���裺�ⴹֱ����:kz=k-----
%-----------����------------
LayerN=4;
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
%-----------�������-------
global Sunspectrum;
load 'Sunspectrum.txt';%̫�������
Sun_E=sum(Sunspectrum(:,2));%��λ���̫�����ǿ


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
xlabel('wavelength / nm'); % x��ע��
ylabel('%'); 
title('R'); % ͼ�α���

grid on; % ��ʾ����

figure
plot(MinL:MaxL,100*myDev_test.T)
xlabel('wavelength / nm'); % x��ע��
ylabel('%'); 
title('T'); % ͼ�α���

grid on; % ��ʾ����

figure
plot(MinL:MaxL,100*myDev_test.A)
xlabel('wavelength / nm'); % x��ע��
ylabel('%'); 
title('A'); % ͼ�α���

grid on; % ��ʾ����

figure
plot(MinL:MaxL,100*myDev_test.R,'-b',MinL:MaxL,100*myDev_test.T,'--r',MinL:MaxL,100*myDev_test.A,'-.k');
xlabel('wavelength / nm'); % x��ע��
ylabel('%'); 
title('RTA'); % ͼ�α���
legend('R','T','A');
grid on; % ��ʾ����

