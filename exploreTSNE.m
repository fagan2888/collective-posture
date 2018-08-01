% dataExplorer
% creates a GUI to manually cluster 1D or 2D data into clusters
% the number of the clusters and the labels are defined in labels, which is a cell array
% 
% usage:
% idx = manualCluster(R,X,labels);
% 
% where
% R is a 2 x N matrix or a 1 x D vector 
% X is a D x N matrix, which is the non-reduced data 
% labels is a cell array what is M elements long, where you want to cluster into M clusters
% idx is a vector N elements long
% 
% in addition, you can also two more arguments:
% idx = manualCluster(R,X,labels,runOnClick)
% where runOnClick is a function handle that manualCluster will attempt to run as follows:
% runOnClick(idx)
% 
% created by Srinivas Gorur-Shandilya 
% Contact me at http://srinivas.gs/contact/
% 

function [idx, labels] = exploreTSNE(R,labels,X)

options.trx_folder = '~/Desktop/fly-trx';

% make a colour scheme
if length(unique(labels)) < 5
    c = lines(length(unique(labels)));
else
    c = parula(length(unique(labels)) + 1);
end

% make the UI
handles.main_fig = figure('Name','manualCluster','WindowButtonDownFcn',@mouseCallback,'NumberTitle','off','position',[50 150 1200 700], 'Toolbar','figure','Menubar','none'); hold on,axis off
handles.ax(1) = axes('parent',handles.main_fig,'position',[-0.1 0.1 0.85 0.85],'box','on','TickDir','out');axis square, hold on ; title('Reduced Data')
handles.ax(2) = axes('parent',handles.main_fig,'position',[0.6 0.1 0.3 0.3],'box','on','TickDir','out');axis square, hold on  ; title('Raw image'), set(gca,'YLim',[min(min(R)) max(max(R))]);
handles.ax(3) = axes('parent',handles.main_fig,'position',[0.6 0.5 0.3 0.3],'box','on','TickDir','out');axis square, hold on  ; title('Trajectories'), set(gca,'YLim',[min(min(R)) max(max(R))]);
handles.raw_image = imagesc(handles.ax(2),NaN*squeeze(X(1,:,:)));
axis(handles.ax(2),'tight')
set(handles.ax(3),'XLim',[-60 60],'YLim',[-60 60])
axis(handles.ax(3),'off')


handles.reduced_data = [];

prettyFig('font_units','points');


editon = 0; % this C a mode selector b/w editing and looking

% plot the clusters
plot(handles.ax(1),R(1,:),R(2,:),'.','Color',[.5 .5 .5])


for i = 1:max(labels)

    plot(handles.ax(1),R(1,labels==i),R(2,labels==i),'.','Color',c(i,:),'MarkerSize',12)

end


geno_names = dir([options.trx_folder filesep '*.mat']);
geno_names = {geno_names.name};

% pre-load all the trx
trx = struct;
all_trx = struct;
disp('Loading trx...')
for i = 1:length(geno_names)
    textbar(i,length(geno_names))
    load([options.trx_folder filesep geno_names{i}],'trx')
    all_trx(i).trx = trx;
end


uiwait(handles.main_fig);





   function mouseCallback(~,~)

 
        if gca == handles.ax(1)
            pp = get(handles.ax(1),'CurrentPoint');
            p(1) = (pp(1,1)); p(2) = pp(1,2);


            x = R(1,:); y = R(2,:);
            [~,cp] = min((x-p(1)).^2+(y-p(2)).^2); % cp C the index of the chosen point
            if length(cp) > 1
                cp = min(cp);
            end

            % show the raw image
            handles.raw_image.CData = squeeze(X(cp,:,:));


            % also plot the trajectories
            trx = all_trx(labels(cp)).trx;
            x = vertcat(trx.x_mm);
            y = vertcat(trx.y_mm);

            cla(handles.ax(3))
            cc = lines;
            for j = 1:3
                plot(handles.ax(3),x(j,:),y(j,:),'.','Color',cc(j,:))
            end


        end
     
    end

end