% This code show a demo run for a set of parameters 
% based on FFT TGV code

function fft_demo(a,b,c,d,e)
% ADMM parameters
nite = 100; % number of iterations
% balancing weights for Total Variation
alpha = a;  % 1st order
beta = b; % 2nd order


% Loading data   

ffcdata=load('GroundTruth');
GroTru=ffcdata.data(:,:,1,1);

%fname = 'parrotgray.png';
%I = im2double( imread( fname ) );
%I0 = I; % original as the reference

% Adding noise
rng(e); %reproducibility
noise_img = imnoise(GroTru,'gaussian',c,d);
%noise_img = GroTru+randn(size(GroTru))*0.3; % white Gaussian noise added to the image
	

denoise_img = zeros( size(GroTru) ); %Preallocation

% Calling TGV fucntion
for c = 1:size(GroTru,3)
	denoise_img(:,:,c) = fft_tgv( noise_img(:,:,c), alpha, beta, nite );
end


% PSNR
psnr_noisy = psnr(noise_img,GroTru);
psnr_tgv = psnr(denoise_img,GroTru);

% SSIM
[mssim, ssim_map] = ssim(denoise_img,GroTru);

% MS SSIM
[ms_ssim, ms_ssim_map] = multissim(denoise_img,GroTru);

% FSIM
fsim=FeatureSIM(GroTru,denoise_img);

% ESSIM
essim=ESSIM(GroTru,denoise_img);

%PSNR HVS
psnr_hvs=psnrhvsm(GroTru,denoise_img);

% PSNR HMA
psnr_hma=psnrhma(GroTru, denoise_img);

% SR SIM
srsim=SR_SIM(GroTru, denoise_img);


% Displaying results

figure(1), imshow( [GroTru, noise_img, denoise_img] );
title( sprintf('From the left,  original,  noisy %.6fdB, TGV %.6fdB \n SSIM: %.8f FSIM: %.8f\n ESSIM: %.8f PSNR HVS: %.8f PSNR HMA: %.8f\n MS SSIM: %.8f SR SIM: %.8f', psnr_noisy, psnr_tgv, mssim, fsim,essim,psnr_hvs,psnr_hma, ms_ssim,srsim) );
end