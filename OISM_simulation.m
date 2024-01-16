
function [Img_Amy]=OISM_simulation(thetaxx)
N_obj_sam=1024;  %采样频率
D=1;%% 圆孔径mm
plotW=2;%% 绘图宽度mm
z=15; %% 衍射距离 mm
lambda=632.8e-6; %% 波长mm
N=4;%% 补零数
theta0=0;%% 入射角   0*pi/180
sam=128;
%============================================
%物光场
    plotW2=plotW/2;
    R=D/2;
    Obj_x=linspace(-plotW2,plotW2,N_obj_sam);
    [Obj_x,Obj_y]=meshgrid(Obj_x,Obj_x);
    Obj_A2=zeros(N_obj_sam);Obj_P=Obj_A2;
    
    dh=0.008;
    lh=0.002;
    a=thetaxx;sf=randn(N_obj_sam/2^a)*sqrt(1);
    sf1=imresize(sf,2^a);
    Obj_P1=2*pi*sf1;
    Obj_A2(((Obj_x*cos(theta0)).^2+Obj_y.^2)<=R^2)=1;
    Obj_E=Obj_A2.*exp(1i*Obj_P1);
%============================================
%物光场补零
    Obj_Ezf=F_ZerosFilling(Obj_E,N_obj_sam,N*N_obj_sam);
    A=fftshift(fft2(fftshift(Obj_Ezf)));
    [m,n]=size(A);%% 角谱的规格
    dtheta=lambda/(N*plotW);%% 角谱角分辨率
    A_x=(-m/2:m/2-1)*dtheta;A_y=(-n/2:n/2-1)*dtheta;% 角谱的角分布
    [A_x,A_y]=meshgrid(A_x,A_y);%% 构造角谱
%角谱传播
    k=2*pi/lambda;%波矢量
    H=exp(1i*k*z*sqrt(1-(A_x.^2+A_y.^2)));
    B=A.*H;
%逆变换成像传播
    Img_Ezf=fftshift(ifft2(fftshift(B)));
    Img_E=F_UnZerosFilling(Img_Ezf,N_obj_sam*2);
subplot(231)
    F_2DPlot(Obj_A2,plotW2,'mm','mm',strcat('物透过率 R=',num2str(R),'mm'))
subplot(232)
    F_2DPlot(Obj_P,plotW2,'mm','mm',strcat('物相位 \lambda=',num2str(lambda*10^6),'nm'))
subplot(233)
    x_plot_obj=linspace(-plotW2,plotW2,N_obj_sam);
    plot(x_plot_obj,Obj_A2(N_obj_sam/2,:),'color',[0 0 0],'LineWidth',3)
    xlabel('mm');ylabel('I');xlim([-plotW2 plotW2]);
    title(strcat('通光孔径 D=',num2str(D),'mm'))  
subplot(234)
Img_A2=F_NorOne(abs(Img_E).^2);
Img_Amy=Img_A2(N_obj_sam-sam/2:N_obj_sam+sam/2-1,N_obj_sam-sam/2:N_obj_sam+sam/2-1);
    F_2DPlot(Img_A2,plotW,'mm','mm',strcat('像面光斑 z=',num2str(z),'mm'))
subplot(235)
    F_2DPlot(angle(Img_E),plotW,'mm','mm','像面相位')
subplot(236)
    x_plot_img=linspace(-plotW,plotW,N_obj_sam*2);
    plot(x_plot_img,Img_A2(N_obj_sam,:),'color',[0 0 0],'LineWidth',3)
    xlabel('mm');ylabel('I');xlim([-plotW plotW]);
    title(strcat('艾里斑半径理论值 R_A_i_r_y= 1.22\lambdaz/D=',num2str(1.22*lambda*z/D),'mm'))
end

function F_2DPlot(z,k,xl,yl,tl)
%本函数目的：绘制3维曲面图，去边框，带标题和label
%输入变量：k为放缩坐标轴的因子
image([-1*k 1*k],[-1*k 1*k],z,'CDataMapping','scaled')
xlabel(xl);
ylabel(yl);
title(tl);
axis xy
axis equal
xlim([-1*k 1*k]);
ylim([-1*k 1*k]);
view([0 90]);
end
 
function MFill=F_ZerosFilling(MOnes,aOnes_F,NumPixcel)
%子函数序号#7
MFill=zeros(NumPixcel);
[aOnes_T,~]=size(MOnes);%实际输入的波前函数，可以是366或367
StartP=(NumPixcel-aOnes_F)/2;%获取规格差距
MFill(StartP+1:StartP+aOnes_T,StartP+1:StartP+aOnes_T)=MOnes;
end
 
function O_A2_Plot=F_UnZerosFilling(O_A2,Samp_p)
[a,b]=size(O_A2);
O_A2_Plot=O_A2(a/2-Samp_p/2+1:a/2+Samp_p/2,b/2-Samp_p/2+1:b/2+Samp_p/2);
end
 
function A_n=F_NorOne(A)
mA=min(A(:));
A=A-mA;
MA=max(A(:));
A_n=A/MA;
end
