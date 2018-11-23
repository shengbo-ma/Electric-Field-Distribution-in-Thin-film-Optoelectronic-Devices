%-------------------------��ʼ��������-----------------------------
%	���ȵ�λ��nm
%	���裺�ⴹֱ����:kz=k-----
%-----------����------------
LayerN=4;
%--------ÿ����-----------
load 'd.txt';%������,�����缫
%----------����ɫɢ����----------
global ITO Ag P3HT_PCBM Al;
ITO=load('ITO.txt');
Ag=load( 'Ag.txt');
P3HT_PCBM=load( 'P3HT-PCBM.txt');
Al=load ('Al.txt');
%-----------�������-------
global Sunspectrum;
load 'Sunspectrum.txt';%̫�������
load 'Sun_E.mat'

%---------������Χ-----------
%ȡ300nm-900nm
global wavelength MaxL MinL;
MaxL=900;
MinL=300;
wavelength=MinL:MaxL;
%   ���䡢͸�䡢������
R=wavelength;
T=wavelength;
A=wavelength;

%--------΢ǻ������½�-------
MaxD=1000;
MinD=1;

%----------�л�����΢ǻ�е�λ��-------
DiploePos=0.5;%Position of Dipole (0~1)

%-------------------------�����������-----------------------------------

%-------------------------�����ʼ��-------------------------------------
%���վ������ض�������ǻ���µ�������
Absorb=zeros(MaxD-MinD+1,MaxL-MinL+1);
Absorb_OrgOnly=zeros(MaxD-MinD+1,MaxL-MinL+1);
Absorb_InorgOnly=zeros(MaxD-MinD+1,MaxL-MinL+1);
%��������Ҫ���ղ���Ag���л���

%�����ҵ�����:һ������
%6�㣺����Ϊ��������ITOǻ���л��㣬ITOǻ������Ag�㣬����
myFilm=film(d(1),Al,'Al');
myFilm(2)=film(d(2),ITO,'ITO');
myFilm(3)=film(d(3),P3HT_PCBM,'P3HT_PCBM');
myFilm(4)=film(d(4),ITO,'ITO');
myFilm(5)=film(d(5),Ag,'Ag');
myFilm(6)=film(d(6),ITO,'ITO');
myDev=device;
myDev=AddLayer(myDev,myFilm);

%����ITO���Ⱥ�һ��
dITO=1000;
%��������������ֻ��Org�����գ������㲻���գ�����Org������
myDev(2)=myDev;
myDev(2).Layers(1).nk(:,3)=zeros(MaxL-MinL+1,1);%Al��nk�����鲿Ϊ��
myDev(2).Layers(2).nk(:,3)=zeros(MaxL-MinL+1,1);%ITO(1)��nk�����鲿Ϊ��
myDev(2).Layers(4).nk(:,3)=zeros(MaxL-MinL+1,1);%ITO(2)��nk�����鲿Ϊ��
myDev(2).Layers(5).nk(:,3)=zeros(MaxL-MinL+1,1);%Ag��nk�����鲿Ϊ��
myDev(2).Layers(6).nk(:,3)=zeros(MaxL-MinL+1,1);%ITO(3)��nk�����鲿Ϊ��

for k=MinD:MaxD%����΢ǻ���
   myDev(2).Layers(4).d=k;
   myDev(2).Layers(2).d=dITO-k;
   [R,T,A]=RTA_surfL(myDev(2),wavelength);
    
    Absorb_OrgOnly(k-MinD+1,:)=A;
    
end

%��������������Org�㲻���գ���������������
myDev(3)=myDev(1);
myDev(3).Layers(3).nk(:,3)=zeros(MaxL-MinL+1,1);%Org��nk�����鲿Ϊ��
for k=MinD:MaxD%����΢ǻ���
    myDev(3).Layers(4).d=k;
    myDev(3).Layers(2).d=dITO-k;
   [R,T,A]=RTA_surfL(myDev(3),wavelength);
    
    Absorb_InorgOnly(k-MinD+1,:)=A;
    
end

%���л���������,Ag��Al���л��㶼������


for k=MinD:MaxD%����΢ǻ���
    myDev(1).Layers(4).d=k;
    myDev(1).Layers(2).d=dITO-k;
   [R,T,A]=RTA_surfL(myDev(1),wavelength);
    
    Absorb(k-MinD+1,:)=A;
    
end
    
%�����ʵ�    
%plot(wavelength,R)
%plot(wavelength,T)
%plot(wavelength,A)

%���չ�ǿ��
%plot(wavelength,R.*Sunspectrum(:,2).')
%plot(wavelength,A.*Sunspectrum(:,2).')

%����΢ǻ���

r=Absorb_OrgOnly./(Absorb_InorgOnly+Absorb_OrgOnly);
Org_A=Absorb.*r;
%{
for i=MinD:MaxD%��������1�Ĳ��֣�ǿ��Ϊ1
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




