function monte_sim_fft(N)

help imtgvsmooth

%% Preallocate:
H=zeros(N,8);   % preallocate storage for all value
T=zeros(N,1);   % preallocate storage for alpha
V=zeros(N,1);   % preallocate storage for beta
U=zeros(N,1);   % preallocate storage for SSIM
P=zeros(N,1);   % preallocate storage for PSNR
Q=zeros(N,1);   % preallocate storage for MS SSIM
X=zeros(N,1);   % preallocate storage for MSE
Y=zeros(N,1);   % preallocate storage for Brisque
Z=zeros(N,1);   % preallocate storage for ESSIM

%% ADMM parameters
nite = 100; % number of iterations
% balancing weights for Total Variation
%alpha = 0.09;  % 1st order
%beta = 0.11; % 2nd order

% load an image
%% Loading data   

ffcdata=load('GroundTruth');        %load Ground Truth data
GroTru=ffcdata.data(:,:,1,1);       %load a Ground Truth image

%fname = 'parrotgray.png';
%I = im2double( imread( fname ) );
%I0 = I; % original as the reference

%% Adding noise

rng(0);                     %reproducibility for next time
noise_img = GroTru+randn(size(GroTru))*0.1;   % adding Gaussian noise
	
denoise_img = zeros( size(GroTru) ); %preallocate for denoise image

%% Monte Carlo simulation:

count=0;
format long;
tic
     for i=1:N
        
        % Random seed:
        rng shuffle     %produce different seed each time
        alpha=rand(1,1);
        beta=rand(1,1);
       
        % Store parameters
        T(i)=alpha;
        V(i)=beta;
        
        %Call TGV:
        for c = 1:size(GroTru,3)
        denoise_img(:,:,c) = fft_tgv( noise_img(:,:,c), alpha, beta, nite );
        end
        
        %SSIM
        [mssim, ssim_map] = ssim(denoise_img, GroTru);
        [mulmssim,mulssim_map]=multissim(denoise_img,GroTru);
        
        %MSE
        err = immse(denoise_img, GroTru);
        
        %Brisque
        score = brisque(denoise_img);

        %PSNR
        psnr_tgv = psnr(denoise_img,GroTru);
        
        %ESSIM
        essim_value=ESSIM(GroTru,denoise_img);
        
        % Store MSSIM and PSNR:
        U(i)=mssim;
        P(i)=psnr_tgv;
        Q(i)=mulmssim;
        X(i)=err;
        Y(i)=score;
        Z(i)=essim_value;
        count=count+1;

        % Dsiplaying results
        sprintf('step: %d, alpha: %.3f, beta: %.3f and mssim: %.8f', count, alpha, beta, mssim)
        
     end

toc
%% Save data:
    
    H(:,1)=T; %alpha
    H(:,2)=V; %beta
    H(:,3)=U; %MSSIM
    H(:,4)=P; %PSNR
    H(:,5)=Q; %MS SSIM
    H(:,6)=X; %MSE
    H(:,7)=Y; %Brisque
    H(:,8)=Z; %ESSIM
         
    savefile=sprintf('DATA/fft_%d_v1.mat',N); %create file name
    save(savefile,'H'); % save matrix H to file
    
 %% find maximum MSSIM:

[zmax1,loc1] = max(H(:,3));
a1=loc1;
xmax1=H(a1,1);
ymax1=H(a1,2);
psnr_value1=H(a1,4);
output1=sprintf('Step: %d, max MSSIM= %.8f, PSNR= %.8f \n alpha= %.6f, beta= %.6f',a1,zmax1, psnr_value1,xmax1,ymax1)

%% find maximum Multi MSSIM:

[zmax2,loc2] = max(H(:,5));
a2=loc2;
xmax2=H(a2,1);
ymax2=H(a2,2);
psnr_value2=H(a2,4);
output2=sprintf('Step: %d, max Multi MSSIM= %.8f, PSNR= %.8f \n alpha= %.6f, beta= %.6f',a2,zmax2, psnr_value2,xmax2,ymax2)

%% find minimum MSE:

[zmin,loc3] = min(H(:,6));
a3=loc3;
xmin=H(a3,1);
ymin=H(a3,2);
psnr_value3=H(a3,4);
output3=sprintf('Step: %d, min MSE= %.8f, PSNR= %.8f \n alpha= %.6f, beta= %.6f',a3,zmin, psnr_value3, xmin,ymin)

%% find minimum Brisque:

[zmin1,loc4] = min(H(:,7));
a4=loc4;
xmin1=H(a4,1);
ymin1=H(a4,2);
psnr_value4=H(a4,4);
mssim4=H(a4,3);
output4=sprintf('Step: %d, min brisque= %.8f, PSNR= %.8f \n alpha= %.6f, beta= %.6f, MSSIM: %.6f',a4,zmin1, psnr_value4, xmin1,ymin1,mssim4)

%% find maximum ESSIM:

[zmax3,loc5] = max(H(:,8));
a5=loc5;
xmax5=H(a5,1);
ymax5=H(a5,2);
psnr_value5=H(a5,4);
output5=sprintf('Step: %d, max ESSIM= %.8f, PSNR= %.8f \n alpha= %.6f, beta= %.6f',a5,zmax3, psnr_value5,xmax5,ymax5)

    
 %% Plotting:
 
 % Plot dot alpha-beta-SSIM
 figure(3)
 plot3(H(:,1),H(:,2),H(:,3),'.')
  title('FFT code alpha vs beta vs SSIM')
   title('FFT code \alpha_0 vs \alpha_1 vs SSIM')
 xlabel('\alpha_1 value')
 ylabel('\alpha_0 value')
 zlabel('Mean SSIM')
 
end