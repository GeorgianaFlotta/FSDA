function out  = ctlcurves(Y, varargin)
%ctlcurves computes Classification Trimmed Likelihood Curves
%
%<a href="matlab: docsearchFS('ctlcurves')">Link to the help function</a>
%
%   ctlcurves applies tclust several times on a given dataset while
%   parameters alpha and k are altered. The resulting object gives an idea
%   of the optimal trimming level and number of clusters considering a
%   particular dataset.
%
%  Required input arguments:
%
%            Y: Input data. Matrix. Data matrix containing n observations
%               on v variables, Rows of Y represent observations, and
%               columns represent variables. Observations (rows) with
%               missing (NaN) or or infinite (Inf) values will
%               automatically be excluded from the computations.
%                 Data Types -  double
%
%  Optional input arguments:
%
%           kk: number of mixture components. Integer vector. Integer
%               vector specifying the number of mixture components
%               (clusters) for which trimmed likelihoods are calculated.
%               Vector. The default value of kk is 1:5.
%                 Example - 'kk',1:4
%                 Data Types - int16 | int32 | single | double
%
%        alpha: trimming level to monitor. Vector. Vector which specifies the
%               values of trimming levels which have to be considered.
%               For example if alpha=[0 0.05 0.1] ctlcurves considers these 3
%               values of trimming level.
%               The default for alpha is vector 0:0.02:0.10;
%                 Example - 'alpha',[0 0.05 0.1]
%                 Data Types -  double
%
%       mixt  : Mixture modelling or crisp assignment. Scalar.
%               Option mixt specifies whether mixture modelling or crisp
%               assignment approach to model based clustering must be used.
%               In the case of mixture modelling parameter mixt also
%               controls which is the criterion to find the untrimmed units
%               in each step of the maximization.
%               If mixt >=1 mixture modelling is assumed else crisp
%               assignment. The default value is mixt=0 (i.e. crisp assignment).
%               In mixture modelling the likelihood is given by:
%                \[
%                \prod_{i=1}^n  \sum_{j=1}^k \pi_j \phi (y_i; \; \theta_j),
%                \]
%               while in crisp assignment the likelihood is given by:
%               \[
%               \prod_{j=1}^k   \prod _{i\in R_j} \phi (y_i; \; \theta_j),
%               \]
%               where $R_j$ contains the indexes of the observations which
%               are assigned to group $j$.
%               Remark - if mixt>=1 previous parameter equalweights is
%               automatically set to 1.
%               Parameter mixt also controls the criterion to select the
%               units to trim,
%               if mixt = 2 the h units are those which give the largest
%               contribution to the likelihood that is the h largest
%               values of:
%               \[
%                   \sum_{j=1}^k \pi_j \phi (y_i; \; \theta_j)   \qquad
%                    i=1, 2, ..., n,
%               \]
%               else if mixt=1 the criterion to select the h units is
%               exactly the same as the one which is used in crisp
%               assignment. That is: the n units are allocated to a
%               cluster according to criterion:
%               \[
%                \max_{j=1, \ldots, k} \hat \pi'_j \phi (y_i; \; \hat \theta_j)
%               \]
%               and then these n numbers are ordered and the units
%               associated with the largest h numbers are untrimmed.
%                   Example - 'mixt',1
%                   Data Types - single | double
%
%  restrfactor: Restriction factor. Scalar. Positive scalar which
%               constrains the allowed differences
%               among group scatters. Larger values imply larger differences of
%               group scatters. On the other hand a value of 1 specifies the
%               strongest restriction forcing all eigenvalues/determinants
%               to be equal and so the method looks for similarly scattered
%               (respectively spherical) clusters. The default is to apply
%               restrfactor to eigenvalues. In order to apply restrfactor
%               to determinants it is is necessary to use optional input
%               argument cshape.
%                 Example - 'restrfactor',12
%                 Data Types -  double
%
%
%       nsamp : number of subsamples to extract. Scalar or matrix.
%               If nsamp is a scalar it contains the number of subsamples
%               which will be extracted. If nsamp=0 all subsets will be
%               extracted.
%               Remark - if the number of all possible subset is <300 the
%               default is to extract all subsets, otherwise just 300.
%               - If nsamp is a matrix it contains in the rows the indexes
%                 of the subsets which have to be extracted. nsamp in this
%                 case can be conveniently generated  by function subsets.
%                 nsamp can have k columns or k*(v+1) columns. If nsamp has
%                 k columns the k initial centroids each iteration i are
%                 given by X(nsamp(i,:),:) and the covariance matrices are
%                 equal to the identity.
%               - If nsamp has k*(v+1) columns the initial centroids and
%                 covariance matrices in iteration i are computed as follows
%                 X1=X(nsamp(i,:),:)
%                 mean(X1(1:v+1,:)) contains the initial centroid for group 1
%                 cov(X1(1:v+1,:)) contains the initial cov matrix for group 1               1
%                 mean(X1(v+2:2*v+2,:)) contains the initial centroid for group 2
%                 cov((v+2:2*v+2,:)) contains the initial cov matrix for group 2               1
%                 ...
%                 mean(X1((k-1)*v+1:k*(v+1))) contains the initial centroids for group k
%                 cov(X1((k-1)*v+1:k*(v+1))) contains the initial cov matrix for group k
%               REMARK - if nsamp is not a scalar option option below
%               startv1 is ignored. More precisely if nsamp has k columns
%               startv1=0 elseif nsamp has k*(v+1) columns option startv1=1.
%                 Example - 'nsamp',1000
%                 Data Types - double
%
%    refsteps : Number of refining iterations. Scalar. Number of refining
%               iterations in subsample.  Default is 15. refsteps = 0 means
%               "raw-subsampling" without iterations.
%                 Example - 'refsteps',10
%                 Data Types - single | double
%
%     reftol  : scalar. Default value of tolerance for the refining steps.
%               The default value is 1e-14;
%                 Example - 'reftol',1e-05
%                 Data Types - single | double
%
%equalweights : cluster weights in the concentration and assignment steps.
%               Logical. A logical value specifying whether cluster weights
%               shall be considered in the concentration, assignment steps
%               and computation of the likelihood.
%                 Example - 'equalweights',true
%                 Data Types - Logical
%
%      startv1: how to initialize centroids and cov matrices. Scalar.
%               If startv1 is 1 then initial
%               centroids and and covariance matrices are based on (v+1)
%               observations randomly chosen, else each centroid is
%               initialized taking a random row of input data matrix and
%               covariance matrices are initialized with identity matrices.
%               Remark 1- in order to start with a routine which is in the
%               required parameter space, eigenvalue restrictions are
%               immediately applied. The default value of startv1 is 1.
%               Remark 2 - option startv1 is used just if nsamp is a scalar
%               (see for more details the help associated with nsamp).
%                 Example - 'startv1',1
%                 Data Types - single | double
%
%     restrtype : type of restriction. Character. The type of restriction to
%               be applied on the cluster scatter
%               matrices. Valid values are 'eigen' (default), or 'deter'.
%               eigen implies restriction on the eigenvalues while deter
%               implies restriction on the determinants. If restrtype is
%               'deter' it is possible to control the constraints on the
%               shape matrices using optional input argument cshape.
%                 Example - 'restrtype','deter'
%                 Data Types - char
%
%       bands  : confidence bands for the curves. boolean or struct. If
%               bands is a scalar boolean equal to true 50 per cent
%               confidence bands are computed (and are shown on the screen
%               if plots=1).
%               If bands is a struct it may contain the following fields:
%               bands.conflev = scalar in the interval (0 1) which contains
%                   the confidence level of the bands.
%               bands.nsimul = number of replicates to use to create the
%                   confidence bands. The default value of bands.nsimul is
%                   100.
%                 Example - 'bands',true
%                 Data Types - logical | struct
%
%       plots : Plot on the screen. Scalar. If plots = 1, a plot of the
%               CTLcurves is shown on the screen. If input option bands is
%               not empty confidence bands are also shown.
%                 Example - 'plots',1
%                 Data Types - single | double
%
%     numpool : number of pools for parellel computing. Scalar.
%               If numpool > 1, the routine automatically checks if
%               the Parallel Computing Toolbox is installed and distributes
%               the random starts over numpool parallel processes. If
%               numpool <= 1, the random starts are run sequentially. By
%               default, numpool is set equal to the number of physical
%               cores available in the CPU (this choice may be inconvenient
%               if other applications are running concurrently). The same
%               happens if the numpool value chosen by the user exceeds the
%               available number of cores.
%               REMARK 1: Unless you adjust the cluster profile, the
%               default maximum number of workers is the same as the
%               number of computational (physical) cores on the machine.
%               REMARK 2: In modern computers the number of logical cores
%               is larger than the number of physical cores. By default,
%               MATLAB is not using all logical cores because, normally,
%               hyper-threading is enabled and some cores are reserved to
%               this feature.
%               REMARK 3: It is because of Remarks 3 that we have chosen as
%               default value for numpool the number of physical cores
%               rather than the number of logical ones. The user can
%               increase the number of parallel pool workers allocated to
%               the multiple start monitoring by:
%               - setting the NumWorkers option in the local cluster profile
%                 settings to the number of logical cores (Remark 2). To do
%                 so go on the menu "Home|Parallel|Manage Cluster Profile"
%                 and set the desired "Number of workers to start on your
%                 local machine".
%               - setting numpool to the desired number of workers;
%               Therefore, *if a parallel pool is not already open*,
%               UserOption numpool (if set) overwrites the number of
%               workers set in the local/current profile. Similarly, the
%               number of workers in the local/current profile overwrites
%               default value of 'numpool' obtained as feature('numCores')
%               (i.e. the number of physical cores).
%                 Example - 'numpool',4
%                 Data Types - double
%
%  cleanpool :  clean pool. Scalar. cleanpool is 1 if the parallel pool has
%               to be cleaned after the execution of the routine. Otherwise
%               it is 0. The default value of cleanpool is 0. Clearly this
%               option has an effect just if previous option numpool is >
%               1.
%                 Example - 'cleanpool',1
%                 Data Types - single | double
%
%       msg  :  Message on the screen. Scalar. Scalar which controls whether
%               to display or not messages about code execution.
%                 Example - 'msg',1
%                 Data Types - single | double
%
%      nocheck: Check input arguments. Scalar. If nocheck is equal to 1
%               no check is performed on matrix Y. As default nocheck=0.
%                 Example - 'nocheck',10
%                 Data Types - single | double
%
%       Ysave : save input matrix. Boolean.
%               Boolan that is set to true to request that the input matrix Y
%               is saved into the output structure out. Default is 1, that
%               is  matrix Y is saved inside output structure out.
%                 Example - 'Ysave',false
%                 Data Types - logical
%
%       cshape : constraint to apply to each of the shape matrices.
%                Scalar greater or equal than 1. This options only works
%                is 'restrtype' is 'deter'.
%               When restrtype is deter the default value of the "shape"
%               constraint (as defined below) applied to each group is
%               fixed to $c_{shape}=10^{10}$, to ensure the procedure is
%               (virtually) affine equivariant. In other words, the
%               decomposition or the $j$-th scatter matrix $\Sigma_j$ is
%               \[
%               \Sigma_j=\lambda_j^{1/v} \Omega_j \Gamma_j \Omega_j'
%               \]
%               where $\Omega_j$ is an orthogonal matrix of eigenvectors, $\Gamma_j$ is a
%               diagonal matrix with $|\Gamma_j|=1$ and with elements
%               $\{\gamma_{j1},...,\gamma_{jv}\}$ in its diagonal (proportional to
%               the eigenvalues of the $\Sigma_j$ matrix) and
%               $|\Sigma_j|=\lambda_j$. The $\Gamma_j$ matrices are commonly
%               known as "shape" matrices, because they determine the shape of the
%               fitted cluster components. The following $k$
%               constraints are then imposed on the shape matrices:
%               \[
%               \frac{\max_{l=1,...,v} \gamma_{jl}}{\min_{l=1,...,v} \gamma_{jl}}\leq
%                   c_{shape}, \text{ for } j=1,...,k,
%               \]
%               In particular, if we are ideally searching for spherical
%               clusters it is necessary to set  $c_{shape}=1$. Models with
%               variable volume and spherical clusters are handled with
%               'restrtype' 'deter', $1<restrfactor<\infty$ and $cshape=1$.
%               The $restrfactor=cshape=1$ case yields a very constrained
%               parametrization because it implies spherical clusters with
%               equal volumes.
%                 Example - 'cshape',10
%                 Data Types - single | double
%
%       Remark: The user should only give the input arguments that have to
%               change their default value. The name of the input arguments
%               needs to be followed by their value. The order of the input
%               arguments is of no importance.
%
%
%  Output:
%
%         out:   structure which contains the following fields:
%
%                out.Mu = cell of size length(kk)-by-length(alpha)
%                       containing the estimate of the centroids for each
%                       value of k and each value of alpha. More precisely,
%                       suppose kk=1:4 and alpha=[0 0.05 0.1], out.Mu{2,3}
%                       is a matrix with two rows and v columns containing
%                       the estimates of the centroids obtained when
%                       alpha=0.1.
%            out.Sigma = cell of size length(kk)-by-length(alpha)
%                       containing the estimate of the covariance matrices
%                       for each value of k and each value of alpha. More
%                       precisely, suppose kk=1:4 and alpha=[0 0.05 0.1],
%                       out.Sigma{2,3} is a 3D  array of size v-by-v-by-2
%                       containing the estimates of the covariance matrices
%                       obtained when alpha=0.1.
%            out.Pi   = cell of size length(kk)-by-length(alpha)
%                       containing the estimate of the group proportions
%                       for each value of k and each value of alpha. More
%                       precisely, suppose kk=1:4 and alpha=[0 0.05 0.1],
%                       out.Pi{2,3} is a 3D  array of size v-by-v-by-2
%                       containing the estimates of the covariance matrices
%                       obtained when alpha=0.1.
%            out.IDX   = cell of size length(kk)-by-length(alpha)
%                       containing the final assignment for each value of k
%                       and each value of alpha. More precisely, suppose
%                       kk=1:4 and alpha=[0 0.05 0.1], out.IDX{2,3} is a
%                       vector of length(n) containing the containinig the
%                       assignment of each unit obtained when alpha=0.1.
%                       Elements equal to zero denote unassigned units.
%           out.CTL    = matrix of size length(kk)-by-length(alpha)
%                       containing the values of the trimmed likelihood
%                       curves for each value of k and each value of alpha.
%      out.BandsCTL    = 3D array of size
%                       length(kk)-by-length(alpha)-by-nsimul containing
%                       the nsimul replicates of out.CTL. This output is
%                       present only if input option bands is true or is a
%                       struct.
%         out.likLB    =  matrix of size length(kk)-by-length(alpha)
%                       containing the lower confidence bands of the
%                       trimmed likelihood curves for each value of k and
%                       each value of alpha. This output is present only if
%                       input option bands is true or is a struct.
%         out.likUB    =  matrix of size length(kk)-by-length(alpha)
%                       containing the upper confidence bands of the
%                       trimmed likelihood curves for each value of k and
%                       each value of alpha. This output is present only if
%                       input option bands is true or is a struct.
%            out.idx  = n-by-1 vector containing assignment of each unit to
%                       each of the k groups in correspodence of
%                       Optimalalpha and OptimalK. Cluster names are
%                       integer numbers from 1 to k. 0 indicates trimmed
%                       observations. This output is present only if input
%                       option bands is true or is a struct.
%           out.OptimalK = scalar, optimal number of clusters, stored
%                        as a positive integer value. This output is present
%                       only if optional input argument is true.
%        out.Optimalalpha = scalar, optimal value of trimming. This
%                       output is present only if optional input argument is
%                       true.
%                out.kk = vector containing the values of k (number of
%                       components) which have been considered. This  vector
%                       is equal to input optional argument kk if kk had been
%                       specified else it is equal to 1:5.
%                out.alpha = vector containing the values of the trimming
%                       level which have been considered. This
%                       vector is equal to input optional argument alphavec if alphavec had
%                       been specified else it is equal to [0, 0.01, ..., 0.10].
%         out.restractor = scalar containing the restriction factor
%                       which has been used to compute tclust.
%                out.Y  = Original data matrix Y. The field is present if
%                       option Ysave is set to 1.
%
% More About:
%
% These curves show the values of the trimmed classification
% (log-)likelihoods when altering the trimming proportion alpha and the
% number of clusters k. The careful examination of these curves provides
% valuable information for choosing these parameters in a clustering
% problem. For instance, an appropriate k to be chosen is one that we do
% not observe a clear increase in the trimmed classification likelihood
% curve for k with respect to the k+1 curve for almost all the range of
% alpha values. Moreover, an appropriate choice of parameter alpha may be
% derived by determining where an initial fast increase of the trimmed
% classification likelihood curve stops for the final chosen k (Garcia
% Escudero et al. 2011). This routine adds confidence bands in order to
% provide an automatic criterion in order to choose k and alpha. Optimal
% trimming level is chosen as the smallest value of alpha such that the
% bands for two consecutive values of k intersect.
%
%
% See also tclust, tclustICsol, tclustICplot
%
%
% References:
%
% Garcia-Escudero, L.A.; Gordaliza, A.; Matran, C. and Mayo-Iscar, A.
% (2011), "Exploring the number of groups in robust model-based
% clustering." Statistics and Computing, Vol. 21, pp. 585�599.
%
% Copyright 2008-2019.
% Written by FSDA team
%
%
%
%<a href="matlab: docsearchFS('ctlcurves')">Link to the help function</a>
%
%$LastChangedDate::                      $: Date of the last commit

% Examples:

%% Beginning of code

nnargin=nargin;
vvarargin=varargin;
Y = chkinputM(Y,nnargin,vvarargin);
[n, v]=size(Y);

% check how many physical cores are available in the computer (warning:
% function 'feature' is undocumented; however, FSDA is automatically
% monitored for errors and other inconsistencies at each new MATLAB
% release).
numpool = feature('numCores');

% User options
% startv1def = default value of startv1 =1, initialization using covariance
% matrices based on v+1 units
startv1=1;

refsteps=15;
reftol=1e-5;

equalweights=false;
restr='eigen';

plots=1;
nsamp=500;
kk=1:5;
msg=1;
alphaTrim=0:0.02:0.10;
%alphaTrim=0:0.04:0.20;

cleanpool=false;
% cshape. Constraint on the shape matrices inside each group which works only if restrtype is 'deter'
cshape=10^10;
restrfactor=100;
mixt=0;
bands=true;

UserOptions=varargin(1:2:length(varargin));
if ~isempty(UserOptions)
    
    options=struct('kk',kk,'mixt',mixt,'alpha',alphaTrim,...
        'nsamp',nsamp,'plots',plots,'nocheck',0,'bands',bands, ...
        'restrfactor', restrfactor, ...
        'msg',msg,'Ysave',1,'refsteps',refsteps,'equalweights',equalweights,...
        'reftol',reftol,'startv1',startv1,'restrtype',restr,'cshape',cshape,...
        'numpool',numpool, 'cleanpool', cleanpool);
    
    
    % Check if number of supplied options is valid
    if length(varargin) ~= 2*length(UserOptions)
        error('FSDA:ctlcurves:WrongInputOpt','Number of supplied options is invalid. Probably values for some parameters are missing.');
    end
    
    % Check if all the specified optional arguments were present
    % in structure options
    % Remark: the nocheck option has already been dealt by routine
    % chkinputR
    inpchk=isfield(options,UserOptions);
    WrongOptions=UserOptions(inpchk==0);
    if ~isempty(WrongOptions)
        disp(strcat('Non existent user option found->', char(WrongOptions{:})))
        error('FSDA:ctlcurves:NonExistInputOpt','In total %d non-existent user options found.', length(WrongOptions));
    end
    
    % Write in structure 'options' the options chosen by the user
    for i=1:2:length(varargin)
        options.(varargin{i})=varargin{i+1};
    end
    
    
    restr=options.restrtype;
    alphaTrim=options.alpha;
    kk=options.kk;
    nsamp=options.nsamp;        % Number of subsets to extract
    plots=options.plots;        % Plot of the resulting classification
    equalweights=options.equalweights;    % Specify if assignment must take into account the size of the groups
    
    refsteps=options.refsteps;
    reftol=options.reftol;
    msg=options.msg;            % Scalar which controls the messages displayed on the screen
    
    mixt=options.mixt;
    cleanpool=options.cleanpool;
    numpool=options.numpool;
    cshape=options.cshape;
    restrfactor=options.restrfactor;
    bands=options.bands;
end

lkk=length(kk);
lalpha=length(alphaTrim);

MuVal = cell(lkk,lalpha);
SigmaVal = MuVal;
PiVal = MuVal;
IDX=MuVal;
CTLVal=zeros(lkk,lalpha);

%% Preapare the pool (if required)
pariter=0;
[numpool,tstart, progbar, usePCT, usematlabpool] = PoolPrepare(numpool, pariter, UserOptions);

CnsampAll=cell(lkk,1);
gRandNumbForNiniAll=CnsampAll;

if isstruct(bands) || (islogical(bands) && bands ==true)
    ComputeBands = true;
else
    ComputeBands = false;
end

for k=1:lkk  % loop for different values of k (number of groups)
    
    seqk=kk(k);
    
    % Cnsamp=subsets(nsamp,n,(v+1)*seqk);
    %seqk = number of groups to consider
    if isscalar(nsamp)
        % For each value of seqk extract subsamples once and for all
        Cnsamp=subsets(nsamp,n,(v+1)*seqk);
    else
        Cnsamp=nsamp;
    end
    
    % For each value of k extract random numbers to initialize proportions
    % once and for all
    gRandNumbForNini=rand(seqk,nsamp);
    
    if ComputeBands==true
        CnsampAll{seqk}=Cnsamp;
        gRandNumbForNiniAll{seqk}=gRandNumbForNini;
    end
    
    parfor (j=1:lalpha , numpool)
        
        alphaTrimj=alphaTrim(j);
        
        outtc=tclust(Y,seqk,alphaTrimj,restrfactor,'nsamp',Cnsamp,'plots',0,'msg',0,'mixt',mixt, ...
            'restrtype',restr,'nocheck',1,'refsteps',refsteps,'equalweights',equalweights,...
            'reftol',reftol,'RandNumbForNini',gRandNumbForNini,'cshape',cshape);
        
        % Store proportions
        [indice] = find(outtc.siz(:,1) >0);
        PiVal{k,j} = outtc.siz(indice,2)/sum(outtc.siz(indice,2));
        
        % columns (j) = values of alpha
        % rows (k) = number of groups
        
        % Store centroids
        MuVal{k,j} = outtc.muopt;
        % Store covariance matrices
        SigmaVal{k,j} = outtc.sigmaopt;
        
        % Store classification
        IDX{k,j} = outtc.idx;
        
        % Store objective function
        CTLVal(k,j) = outtc.obj;
    end
    if msg==1
        disp(['k=' num2str(seqk)])
    end
end

% gamma is the width of the confidence interval divided by 2
gamma=0.25;
% nsimul = default number of simulations to create the bands
nsimul=100;

out=struct;
out.Mu=MuVal;
out.Sigma=SigmaVal;
out.Pi=PiVal;
out.IDX=IDX;
out.CTL=CTLVal;

if ComputeBands==true
    
    if isstruct(bands)
        fbands=fieldnames(bands);
        
        d=find(strcmp('conflev',fbands));
        if d>0
            gamma=(1-bands.conflev)/2;
        end
        
        d=find(strcmp('nsimul',fbands));
        if d>0
            nsimul=bands.nsimul;
        end
    end
    
    % BandsCTL is a 3D array which will contain the replicates for the
    % solutions
    BandsCTL=zeros(lkk,lalpha,nsimul);
    for k=1:lkk  % loop for different values of k (number of groups)
        if msg==1
            disp(['Bands k=' num2str(k)])
        end
        
        % Extract what depends just on k
        seqk=kk(k);
        CnsampAllk=CnsampAll{seqk};
        gRandNumbForNiniAllk=gRandNumbForNiniAll{seqk};
        
        for j=1:lalpha
            
            ktrue = length(PiVal{seqk, j});
            Mutrue = MuVal{seqk, j};
            Mutrue=Mutrue(1:ktrue,:);
            Sigmatrue = SigmaVal{seqk, j};
            Sigmatrue = Sigmatrue(:,:,1:ktrue);
            Pitrue=PiVal{seqk, j};
            alphaTrimj=alphaTrim(j);
            ngood=round(n*(1-alphaTrimj));
            nout=n-ngood;
            parfor (zz = 1:nsimul, numpool)
                [Ysim]=simdataset(ngood, Pitrue, Mutrue, Sigmatrue,'noiseunits', nout);
                if size(Ysim,1)<n
                    Yadd=repmat(Ysim(end,:),n-size(Ysim,1),1);
                    Ysim=[Ysim;Yadd];
                end
                outtcSIM=tclust(Ysim,seqk,alphaTrimj,restrfactor,'nsamp',CnsampAllk,'plots',0,'msg',0,'mixt',mixt, ...
                    'restrtype',restr,'nocheck',1,'refsteps',refsteps,'equalweights',equalweights,...
                    'reftol',reftol,'RandNumbForNini',gRandNumbForNiniAllk,'cshape',cshape);
                
                BandsCTL(k, j, zz) = outtcSIM.obj;
            end
        end
    end
    out.BandsCTL=BandsCTL;
    
    likLB = zeros(length(kk),length(alphaTrim));
    lik050 = likLB;
    likUB =likLB;
    for k=1:length(kk)  % loop for different values of k (number of groups)
        parfor j=1:length(alphaTrim)
            likLB(k,j) = quantile(BandsCTL(k,j,:), gamma);
            lik050(k,j) = median(BandsCTL(k,j,:));
            likUB(k,j) = quantile(BandsCTL(k,j,:), 1- gamma);
        end
    end
    
    out.likLB=likLB;
    out.lik050=lik050;
    out.likUB=likUB;
    conv=0;
    
    for j = 1:length(kk)-1
        alphaBest='';
        for jalpha =1:size(likUB,2)
            if (likUB(j,jalpha) > likLB(j+1,jalpha) &&  lik050(j+1,jalpha)> lik050(j,jalpha)) || ...
                    (likLB(j,jalpha) < likUB(j+1,jalpha) &&  lik050(j+1,jalpha) < lik050(j,jalpha))
                % Find best trimming level
                alphaBest = alphaTrim(jalpha);
                break
            else
            end
            
        end
        
        if ~isempty(alphaBest)
            alphafin = alphaBest;
            kfin = j;
            conv = 1;
            break
        end
    end
    
    
    if conv == 1
        idxOptimal=IDX{kfin,jalpha};
        
        d=strcmp('rew',fbands);
        if d>0 && bands.rew == true
            % Convalidate the groups
            % idxTMP=ones(n,1);
            %  idxTMP=ones(n,kfin);
                seq=1:n;
            for jj=1:kfin
                seqjj=seq(idxOptimal==jj);
                VALjj=FSM(Y(seqjj,:),'msg',0,'plots',0);
                if ~isnan(VALjj.outliers)
                    idxOptimal(seqjj(VALjj.outliers))=0;
                   %  idxOptimal(seqjj(VALjj.outliers),jj)=0;
                end
            end
            % idxOptimal(idxTMP==0)=0;
        end
        
        
        out.idx=idxOptimal;
    else
        disp('No intersection among the curves has been found for the selected trimming levels and number of groups')
        disp('Please increase k or alpha')
        alphafin=[];
        kfin=[];
        out.idx=[];
    end
    
    
    out.Optimalalpha=alphafin;
    out.OptimalK=kfin;
    % Store best classification
end


if plots==1
    if ComputeBands==1
        linetype1 = {'-.','-.','-.','-.','-.'};
        % linetype = {'-','-','-','-','-'};
        color = {'r','g','b','c','k'};
        LineWidth = 1;
        hold('on')
        for i = 1:length(kk)
            plot(alphaTrim,likLB(i,:), 'LineStyle',linetype1{i}, 'Color', color{i}, 'LineWidth', LineWidth)
            % plot(alphaTrim,lik050(i,:), 'LineStyle',linetype{i}, 'Color', color{i}, 'LineWidth', LineWidth)
            text(alphaTrim(end),lik050(i,end),[' k = ' num2str(i)],'FontSize',16, 'Color', color{i})
            plot(alphaTrim,likUB(i,:), 'LineStyle',linetype1{i}, 'Color', color{i}, 'LineWidth', LineWidth)
        end
    else
        plot(alphaTrim, CTLVal)
        for i = kk
            text(alphaTrim,CTLVal(i,:),num2str(i*ones(length(alphaTrim),1)),'FontSize', 14)
        end
    end
    xlabel('Trimming level alpha')
    ylabel('Log likelihood')
    set(gca,'XTick',alphaTrim);
end


out.kk=kk;
out.alpha=alphaTrim;
out.restrfactor=restrfactor;
out.Y=Y;

%% Close pool and show messages if required
PoolClose(cleanpool, tstart, progbar, usePCT, usematlabpool);


end


