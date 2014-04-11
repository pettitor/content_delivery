%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% GLOBAL PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%serverUL=20; %Server uploading bandwidth in Mbps

par.nuser = 4039;  %number of nodes
daily_num=2650;%daily active users --- 66% of N ----

par.nvids=9000; %number of videos
par.vbr=330; %video bit rate MB/s
par.chunk_size=3; % chunk size in MB
par.prefix_length=3; %prefix length in MB

par.cachesizeUSER = 300; %Users cache size in M
%size for prefixes in user's cache in M
cache_size_pr=par.cache_size/5;
%size for videos in user's cache in M
cache_size_vd=(4*par.cache_size)/5;

%%%%%% ASes Information%%%%%%%%
%number of AS

par.ASn = 50;

%weights of ASes - Zipf
par.ASp = geopdf(0:(par.ASn-1), 0.1);
par.ASp(end) = 1-sum(par.ASp(1:end-1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%time slots%%%%%%%%%%%%
%72 slots of 20 minutes and weights that represent 
%the level of activity in each of these slots
%par.twe_min=1:72; %equals index
par.twe_min_weights=[2.1 2 1.8 1.6 1.4 1.3 1.2 1.1 1.1 1 0.9 0.8 0.7 0.8 0.9 0.9 1 1.1 1.3 1.4 1.5 1.6 2 3 3.2 3.7 4.2 4.5 4.8 5.2 5.4 5.7 6.1 6.6 6.5 6.4 6.4 6.5 6.6 6.7 6.7 6.8 6.9 6.9 7 7.1 7 6.9 6.8 6.6 6.4 6.3 6.2 6.1 6 5.9 5.8 5.7 5.8 6 6.1 5.8 5.5 5.3 5.1 4.8 4.6 4 3.5 3.3 2.8 2.4];    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%  Interests%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%number of interest categories

%interest categories ids
%par.int_sum=1:19; %equals index
%weigths of each interest categories - bases on their percentage in total
%video distribution
par.categories=[0.253 0.247 0.086 0.086 0.085 0.075 0.035 0.032 0.023 0.016 0.016 0.011 0.010 0.008 0.005 0.005 0.003 0.002 0.002];

%number of interests per user
par.ncategories = 4;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%viewers categorization thresholds
viewers_perc_onehop=61; %percentage of viewers

foll_perc=31; %percentage of followers

nonfoll_perc_onehop=37; %percentage of noofollowers one hop
nonfoll_perc_twohops=12; %percentage of noofollowers two hops

others_perc_onehop=2; %percentage of other viewers one hop
others_perc_twohops=6; %percentage of other viewers two hops


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%videos related parameters
min_vs=20;%min video size in MB
max_vs= 30;%max video size in MB

min_num_up=155;%min videos to upload in one day 155
max_num_up=230;%max videos to upload in one day 230

min_vid=1; %minimum videos to watch in each step
max_vid=5; %maximum videos to watch in each step

%%%%%%%%%%%%%%%% bandwidth heterogeneity%%%%%%%%%%%%%%%%%%%%%%%%%  

% 3 choices of UL/DL bandwidth - probabities of each choice
%first choice
par.bw=struct('DL',768,'UL',128,'dstr',21.4); 

%second choice
par.bw(2).DL=1536;
par.bw(2).UL=384;
par.bw(2).dstr=23.3;

%third choice
par.bw(3).DL=3072;
par.bw(3).UL=768;
par.bw(3).dstr=55.3;