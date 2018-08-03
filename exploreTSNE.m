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

function exploreTSNE(data)



% make the UI
handles.main_fig = figure('Name','t-SNE Explorer','WindowButtonDownFcn',@mouseCallback,'NumberTitle','off','position',[50 150 1200 700], 'Toolbar','figure','Menubar','none'); hold on,axis off
handles.ax(1) = axes('parent',handles.main_fig,'position',[-0.1 0.1 0.85 0.85],'box','on','TickDir','out');axis square, hold on ; title('Behaviour space')

% show the density map
h = imagesc(handles.ax(1),data.D);
colormap(data.cc)
axis square
axis tight
prettyFig();


handles.ax(2) = axes('parent',handles.main_fig,'position',[0.6 0.1 0.4 0.4],'box','on','TickDir','out');axis square, hold on  ; title('Raw image')
handles.ax(3) = axes('parent',handles.main_fig,'position',[0.6 0.55 0.4 0.4],'box','on','TickDir','out');axis square, hold on  ; title('Trajectories');
handles.raw_image = imagesc(handles.ax(2),NaN*squeeze(data.images(1,:,:)));
axis(handles.ax(2),'tight')
axes(handles.ax(2))

set(handles.ax(3),'XLim',[-60 60],'YLim',[-60 60])
axis(handles.ax(3),'off')
axis(handles.ax(1),'off')

set(handles.ax(2),'XTick',linspace(1,size(data.images(1,:,:),3),5), 'XTickLabel',{'0','\pi/2','\pi','3* \pi/2','2*\pi'})

handles.this_pt = plot(handles.ax(1),NaN,NaN,'ko','MarkerSize',50,'LineWidth',5,'LineStyle','--');


% handles.polar_ax = polaraxes('Parent',handles.main_fig);
% handles.polar_ax.Position = [.6 .73 .25 .25];
% handles.pp = polarplot(handles.polar_ax,0,0,'k.','MarkerSize',15);
% title(handles.polar_ax,'Egocentric representation');


prettyFig('font_units','points');

handles.ax(3).Visible = 'on';

uiwait(handles.main_fig);





   function mouseCallback(~,~)

 
        if gca == handles.ax(1)
            pp = get(handles.ax(1),'CurrentPoint');
            p(1) = (pp(1,1)); p(2) = pp(1,2);


            x = data.y; y = data.x;
            [~,cp] = min((x-p(1)).^2+(y-p(2)).^2); % cp C the index of the chosen point
            if length(cp) > 1
                cp = min(cp);
            end

            handles.this_pt.XData = x(cp);
            handles.this_pt.YData = y(cp);


            % show the raw image
            handles.raw_image.CData = squeeze(data.images(cp,:,:));

            % figure out which genotype this is
            this_geno = data.all_geno(cp);

            this_name = data.geno_names{this_geno};
            if length(this_name) > 20
                this_name = this_name(1:20);
            end

            title(handles.ax(1),this_name,'interpreter','none')

            trx = data.all_trx(this_geno).trx;

            traj_lengths = cellfun(@length,{trx.x});
            rm_this = traj_lengths ~= mode(traj_lengths);


            trx(rm_this) = [];
            x = vertcat(trx.x_mm);
            y = vertcat(trx.y_mm);

            this_frame = data.all_frames(cp);


            a = max(this_frame-500,1);
            z = min(this_frame+500,length(x));


            cla(handles.ax(3))

            for j = 1:size(x,1)
                plot(handles.ax(3),x(j,a:z),y(j,a:z),'.','Color',[.5 .5 .5])
            end

            j = data.all_fly_id(cp);
            plot(handles.ax(3),x(j,a:z),y(j,a:z),'r.','MarkerSize',24)


            handles.ax(3).XLim = [min(x(:)) max(x(:))];
            handles.ax(3).YLim = [min(y(:)) max(y(:))];
            axis(handles.ax(3),'off')

        end
     
    end

end