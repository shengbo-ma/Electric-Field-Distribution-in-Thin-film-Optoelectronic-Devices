%Multispacer厚度匹配
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
myMaterial2(:,2)=5;
myMaterial2(:,3)=0;

%index matching material
IMM=zeros(601,3);
IMM(:,1)=MinL:MaxL;
IMM(:,2)=30;
IMM(:,3)=0;

mySur1=zeros(601,3);
mySur1(:,1)=MinL:MaxL;
mySur1(:,2)=100000;
mySur1(:,3)=0;
%-----------输入光谱-------
global Sunspectrum;
load 'Sunspectrum.txt';%太阳光光谱
Sun_E=sum(Sunspectrum(:,2));%单位面积太阳光光强


%标准器件
%--------每层厚度-----------
cav_d=[120,51,40,10,0,10,0,100];%没考虑LiF层
%-----------------------------
cav_film=film(cav_d(1),Al,'Al');
cav_film(2)=film(cav_d(2),ITO,'ITO');
cav_film(3)=film(cav_d(3),P3HT_PCBM,'P3HT_PCBM');
cav_film(4)=film(cav_d(4),PEDOT,'PEDOT');
cav_film(5)=film(cav_d(5),ITO,'ITO');
cav_film(6)=film(cav_d(6),Au,'Au');
cav_film(7)=film(cav_d(7),IMM,'IMM');
cav_film(8)=film(cav_d(8),ITO,'ITO');


%看某一个单色波长
chosenwl=500;
%看某一波段
minwl=300;
maxwl=900;
%看某一层
chosenLayer=3;
%层命名
OrgNo=3;
spacer1=2;
spacer2=5;
refNo=6;
indmac1=7;

best_d=cav_d;
best_ab=0;
best_wl=0;

max_d=400;
rec=zeros(1,max_d+1);
c=0;
tic
for im1n=0:5
    cav_film(indmac1).d=im1n;
    for refd=cav_d(6):cav_d(6)
        cav_film(refNo).d=refd;
        for s1n=51:51
            cav_film(spacer1).d=s1n;
            for s2n=cav_d(5):cav_d(5)
                cav_film(spacer2).d=s2n;
                cav_dev=device(cav_film);
                cav_dev=Absorb_sunspectrum(cav_dev,minwl,maxwl,OrgNo);
                new_ab=cav_dev.Absorb_sun
                rec(im1n+1)=cav_dev.Absorb_sun;
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
                datestr(now)
            end
        end
    end

end
toc
disp(['在',num2str(best_wl),'nm波长光垂直入射时']);
disp(['有最佳厚度配置',num2str(best_d)]);
disp(['吸收率为',num2str(best_ab)]);
plot(0:max_d,rec)
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
        cav_dev=device(cav_film);
        cav_dev=Absorb_destri_monoE(cav_dev,chosenwl);

        plot_EM_destri(cav_dev);
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
