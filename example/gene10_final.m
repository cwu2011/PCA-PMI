%2015.10.11
%final version
%for result_DREAM gene10 
%%
configpath;
% DATA50=
% GOLD=
% CODE=
% RESULT=
%addpath(CODE);
Type='null-mutants'; % can be set as 'heterozygous'
File={'Yeast1','Yeast2','Yeast3','Ecoli1','Ecoli2'};
%TH=[0.35,0.1850,0.2600, 0.3750,0.4500];
%TH=[0.05,0.010,0.0750, 0.0950,0.0950];
TH=[0.35,0.1850,0.0750, 0.0950,0.4500];%fine tuned threshold for roc_10gene null-mutants
ColorMap=hsv(9);

for i=1:numel(File)
    figure(i);
    cd(DATA10);
    if exist(sprintf('InSilicoSize10-%s-%s.tsv',File{i},Type),'file')
        NullMU=importdata(sprintf('InSilicoSize10-%s-%s.tsv',File{i},Type));
    else
        NullMU=importdata(sprintf('InSilicoSize10-%s-%s.txt',File{i},Type));
    end
    cd(GOLD);
    ANSWER=importdata(sprintf('DREAM3GoldStandard_InSilicoSize10_%s.txt',File{i}));
    cd(CODE)
    NODE=cellfun(@(x)(str2num(x(2:end))),ANSWER.textdata);
    E_ANS=zeros(max(NODE));
    E_ANS(sub2ind(size(E_ANS),NODE(:,1),NODE(:,2)))=ANSWER.data;
    %imagesc(E_ANS)
    E_ANS=E_ANS+E_ANS';
    %%
%     [G1,Gval1,l1]=kpca_pmi(NullMU.data',0.05,1);
%     [G2,Gval2,l2]=pcapcc(NullMU.data',0.3,7);Gval2=abs(Gval2);
%     [G3,Gval3,l3]=pca_cmi(NullMU.data',0.05,1);
%     Gval4=graphicalLasso(corr(NullMU.data),0.2,10^3);Gval4=abs(Gval4);
    [G1,Gval1,l1]=pca_pmi(NullMU.data',TH(i));
    [G2,Gval2,l2]=pcapcc(NullMU.data',sqrt(1-exp(-2*0.05)));Gval2=abs(Gval2);
    [G3,Gval3,l3]=pca_cmi(NullMU.data',0.05);
    Gval4=graphicalLasso(corr(NullMU.data),0.1,10^3);Gval4=abs(Gval4);
    [x1,y1,T1,AUC1,optrocpt1]=perfcurve(squareform(E_ANS),squareform(Gval1'),1);
    [x2,y2,T2,AUC2,optrocpt2]=perfcurve(squareform(E_ANS),squareform(Gval2'),1);
    [x3,y3,T3,AUC3,optrocpt3]=perfcurve(squareform(E_ANS),squareform(Gval3'),1);
    [x4,y4,T4,AUC4,optrocpt4]=perfcurve(squareform(E_ANS),squareform(tril(Gval4',-1)),1);
    %%
    figure(i);
    axes('FontSize',11,'FontWeight','bold','TickDir','in');
%     h1=line(x1,y1,'Color','red','LineWidth',3,'LineStyle','-');hold on;
%     h2=line(x2,y2,'Color',[1,0.5,0],'LineWidth',2.5);hold on;
%     h3=line(x3,y3,'Color',[0.6,0.2,0.8],'LineWidth',3,'LineStyle',':');hold on;
%     h4=line(x4,y4,'Color',[0.26,0.54,0],'LineWidth',2,'LineStyle','--');hold on;

    h2=line(x2,y2,'Color',ColorMap(2,:),'LineWidth',0.7,'LineStyle','--');hold on;
    h3=line(x3,y3,'Color',ColorMap(4,:),'LineWidth',0.5);hold on;
    h4=line(x4,y4,'Color',ColorMap(8,:),'LineWidth',0.7,'LineStyle','--');hold on;
    h1=line(x1,y1,'Color',ColorMap(1,:),'LineWidth',0.8,'LineStyle','-');hold on;
    hleg=legend([h1,h2,h3,h4],sprintf('\\color{red}{PMI AUC=%.3f}',AUC1),sprintf('ParCorr AUC=%.3f',AUC2),sprintf('CMI AUC=%.3f',AUC3),sprintf('Lasso AUC=%.3f',AUC4),'Interpreter','latex');
    %hleg=legend([h2,h3,h4],sprintf('PMI AUC=%.3f',AUC2),sprintf('CMI AUC=%.3f',AUC3),sprintf('CMI2NI AUC=%.3f',AUC4));
    
    set(hleg,'Location','SouthEast','FontSize',15,'FontWeight','bold');
    axis([-0.01,1,0,1.01]);
    xlabel('False Positive Rate','Color','black','FontSize',24,'FontWeight','bold');
    ylabel('True Positive Rate','Color','black','FontSize',24,'FontWeight','bold');
    plot([0 1],[0 1],'color',[0.7,0.7,0.7]);
    title(sprintf('ROC of %s (10 Genes)',File{i}),'Color','black','FontSize',26,'FontWeight','bold');
    %box off;
   %%
    set(gca,'Box','on','GridLineStyle',':','Ycolor',[0,0,0],'Xcolor',[0,0,0],'Color',[0.9,0.9,0.9])
    %grid on;
    legend('boxoff');
    cd(RESULT);
    saveas(gcf,sprintf('%s_gene10.png',File{i}),'png');
    saveas(gcf,sprintf('%s_gene10.eps',File{i}),'psc2');
%     saveas(gcf,sprintf('%s_gene10.tif',File{i}),'tif');
%     saveas(gcf,sprintf('%s_gene10.emf',File{i}),'emf');
end