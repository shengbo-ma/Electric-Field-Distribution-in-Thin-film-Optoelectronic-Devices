%Multispacer���ƥ��
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
myMaterial(:,2)=3;
myMaterial(:,3)=0;

myMaterial2=zeros(601,3);
myMaterial2(:,1)=MinL:MaxL;
myMaterial2(:,2)=5;
myMaterial2(:,3)=0;

%index matching material
IMM=zeros(601,3);
IMM(:,1)=MinL:MaxL;
IMM(:,2)=3;
IMM(:,3)=0;

mySur1=zeros(601,3);
mySur1(:,1)=MinL:MaxL;
mySur1(:,2)=100000;
mySur1(:,3)=0;
%-----------�������-------
global Sunspectrum;
load 'Sunspectrum.txt';%̫�������
Sun_E=sum(Sunspectrum(:,2));%��λ���̫�����ǿ


%��׼����
%--------ÿ����-----------
cav_d=[0,20,0,40,10,0,20,0];%û����LiF��
%-----------------------------
cav_film=film(cav_d(1),IMM,'IMM');
cav_film(2)=film(cav_d(2),Ag,'Ag');
cav_film(3)=film(cav_d(3),ITO,'ITO');
cav_film(4)=film(cav_d(4),P3HT_PCBM,'P3HT_PCBM');
cav_film(5)=film(cav_d(5),PEDOT,'PEDOT');
cav_film(6)=film(cav_d(6),ITO,'ITO');
cav_film(7)=film(cav_d(7),Ag,'Ag');
cav_film(8)=film(cav_d(8),IMM,'IMM');


%��ĳһ����ɫ����
chosenwl=500;
%��ĳһ����
minwl=300;
maxwl=900;
%��ĳһ��
chosenLayer=3;
%������
OrgNo=4;
spacer1=3;
spacer2=6;
refNo=7;
indmac1=1;
indmac2=8;

best_d=cav_d;
best_ab=0;
best_wl=0;
max_dim=50;
max_dos=50;
c=0;
%rec=zeros(1,max_d+1);
rec_matrix=zeros(max_dim+1,max_dos+1);
tic
for im1n=0:max_dim
    cav_film(indmac1).d=im1n;
    for im2n=0:0
        cav_film(indmac2).d=im2n;
        for s1n=0:max_dos
            cav_film(spacer1).d=s1n+15;
            for s2n=0:0
                cav_film(spacer2).d=s2n;
                cav_dev=device(cav_film);
                cav_dev=Absorb_sunspectrum(cav_dev,minwl,maxwl,OrgNo);
                new_ab=cav_dev.Absorb_sun;
                rec_matrix(im1n+1,s1n+1)=cav_dev.Absorb_sun;
                %rec(s1n+1)=cav_dev.Absorb_sun;
                if new_ab>=best_ab
                    for l=1:1:cav_dev.LayerN
                        best_d(l)=cav_dev.Layers(l).d;
                    end
                    best_ab=new_ab;
                end
                %plot_EM_destri(cav_dev);
                %pause(0.01);
                c=c+1;
                c
                best_d
                best_ab
                new_ab
                datestr(now)
            end
        end
    end
end    


toc

disp(['��Ѻ������',num2str(best_d)]);
disp(['������Ϊ',num2str(best_ab)]);

figure
surf(rec_matrix)%�л����հٷֱ�
%set(gca,'XTickLabel',str2num(get(gca,'XTickLabel')));
%set(gca,'YTickLabel',str2num(get(gca,'YTickLabel'))+15);
%axis([0,max_dim,15,max_dos+15]);
xlabel('IML / nm'); % x��ע��
ylabel('OS / nm'); % y��ע��
%title(strcat('�л����հٷֱ�','(����Layer ',num2str(LayerForSurf),')')); % ͼ�α���
colorbar
shading flat
%plot(0:max_d,rec)

%}


%for d1=1:1:51
%	cav_film(2).d=d1; 
%{
figure
    for d=0:maxd
        cav_film(2).d=d;
        cav_dev=device(cav_film);
        cav_dev=Absorb_destri_monoE(cav_dev,chosenwl);
        a(d+1)=Absorb_monoL_monoE(cav_dev,chosenLayer,chosenwl);
        plot_EM_destri(cav_dev);
        pause(0.01);
    end
    figure
plot(0:maxd,a*100);
%}
%title(num2str(d1));
%{
    cav_dev=device(cav_film);
    figure
plot_EM_destri_sunsp(cav_dev,minwl,maxwl);
%end    
%}
  
%{
figure
for d=0:maxd
    cav_film(2).d=d;
    cav_dev=device(cav_film);
    cav_dev=Absorb_sunspectrum(cav_dev,minwl,maxwl,OrgNo);
    a(d+1)=cav_dev.Absorb_sun;
    d
    %plot_EM_destri_sunsp(cav_dev,minwl,maxwl);
end
    figure
plot(0:maxd,a*100);
%}
