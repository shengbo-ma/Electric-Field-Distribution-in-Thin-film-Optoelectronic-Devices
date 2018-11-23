%�Ƚϱ�׼����
%΢ǻ������Heeger����,�ҳ�spacer��Ѻ������

clear
%-------------------------��ʼ��������-----------------------------
%	���ȵ�λ��nm
%	���裺�ⴹֱ����:kz=k-----

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
%-----------�������-------
global Sunspectrum;
load 'Sunspectrum.txt';%̫�������
Sun_E=sum(Sunspectrum(:,2));%��λ���̫�����ǿ

%--------ÿ����-----------
load 'd.txt';%������,�����缫
%-----------------------------

%��׼����
reg_d=[120,40,10,100];%û����LiF��

reg_film=film(reg_d(1),Al,'Al');
reg_film(2)=film(reg_d(2),P3HT_PCBM,'P3HT_PCBM');
reg_film(3)=film(reg_d(3),PEDOT,'PEDOT');
reg_film(4)=film(reg_d(4),ITO,'ITO');

reg_dev=device(reg_film);

%��ĳһ����ɫ����
chosenwl=500;
%��ĳһ����
minwl=300;
maxwl=900;

reg_dev=RTA_surfL(reg_dev, minwl, maxwl);
%}
%{
figure
plot(wavelength,100*reg_dev.R)
xlabel('wavelength / nm'); % x��ע��
ylabel('R(%)'); % y��ע�� PCE=power converting efficiency
title('������'); % ͼ�α���
grid on; % ��ʾ����

figure
plot(wavelength,100*reg_dev.T)
xlabel('wavelength / nm'); % x��ע��
ylabel('T(%)'); % y��ע�� PCE=power converting efficiency
title('͸����'); % ͼ�α���
grid on; % ��ʾ����

figure
plot(wavelength,100*reg_dev.A)
xlabel('wavelength / nm'); % x��ע��
ylabel('A(%)'); % y��ע�� PCE=power converting efficiency
title('������'); % ͼ�α���
grid on; % ��ʾ����
%}

figure
plot(wavelength,100*reg_dev.R,'-b',wavelength,100*reg_dev.T,'--r',wavelength,100*reg_dev.A,'-.k');
xlabel('wavelength / nm'); % x��ע��
ylabel('%'); 
title('RTA'); % ͼ�α���
legend('R','T','A')
grid on; % ��ʾ����
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
xlabel('wavelength / nm'); % x��ע��
ylabel('%'); 
title('���հٷֱ�'); % ͼ�α���
legend('OrgLayer','dev','total')
grid on; % ��ʾ����

reg_dev=Absorb_sunspectrum(reg_dev,minwl,maxwl,OrgNo);
reg_dev.Absorb_sun

figure
plot_EM_destri_sunsp(reg_dev,minwl,maxwl);
%}