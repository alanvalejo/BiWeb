classdef PlotWebs < handle;
   
    properties
       
        pos_x                = []; %X coordinate of each cell in a unit square
        pos_y                = []; %Y coordinate of each cell in a unit square
        cell_color           = [1 1 1]; %Cell color
        back_color           = [0 0 128]/255; %Back color
        margin               = 0.12; %Margin between cels
        ax                   = 'image'; %Axis
        border_color         = 'none';
        border_line_width    = 0.0005;
        
    end
    
    properties
        
        matrix = [];
        biweb                = {};
        row_labels           = {};
        col_labels           = {};
        use_labels           = 1;
        FontSize             = 5;
        index_rows           = [];
        index_cols           = [];
        colors               = [];
        n_rows               = []; %row number
        n_cols               = []; %col number
        
    end
    
    properties
       
        radius                = 0.5;
        vertical_margin       = 0.12;
        horizontal_proportion = 0.5;
        row_pos               = [];
        col_pos               = [];
        bead_color            = [0 0 0];
        link_color            = [0 0 0];
        
    end
    
    methods
       
        function obj = PlotWebs(bipmatrix_or_biweb)
           
            if(isa(bipmatrix_or_biweb,'Bipartite'))
                obj.biweb = bipmatrix_or_biweb;
                obj.matrix = obj.biweb.adjacency;
            else
                obj.matrix = bipmatrix_or_biweb;
            end
            
            [obj.n_rows obj.n_cols] = size(obj.matrix);
            
            obj.colors = colormap('jet');
            obj.colors = obj.colors([23,2,13,42,57,20,15,11,9,16,3,28,26,24,46,59,41,18,56,40,17,48,27,53,6,62,5,60,14,32,64,19,36,58,39,21,4,8,35,30,50,63,25,51,55,34,61,37,47,44,54,43,38,12,52,33,31,1,22,29,10,45,49,7],:);
            
            obj.FillPositions();
            
        end
        
        function obj = FillPositions(obj)
            obj.pos_x = zeros(obj.n_rows,obj.n_cols);
            obj.pos_y = zeros(obj.n_rows,obj.n_cols);

            obj.pos_x = repmat(1:obj.n_cols, obj.n_rows, 1);
            obj.pos_y = repmat(((obj.n_rows+1)-(1:obj.n_rows))',1,obj.n_cols);
            
            maxd = max(obj.n_rows,obj.n_cols);
            obj.row_pos = linspace(maxd,1,obj.n_rows);
            obj.col_pos = linspace(maxd,1,obj.n_cols);
            
        end
        
        function PlotBMatrix(obj)
            cla;
            maxd = max(obj.n_rows,obj.n_cols);
            x1 = 1; x2 = 1+maxd*obj.horizontal_proportion;
            
            obj.index_rows = 1:obj.n_rows;
            obj.index_cols = 1:obj.n_cols;            
            
            local_matrix = obj.matrix;
            
            hold on;
            for i = 1:obj.n_rows
                for j = 1:obj.n_cols
                    if(local_matrix(i,j)==1)
                        plot([1 x2],[obj.row_pos(i) obj.col_pos(j)],'black');
                    end
                end
            end
            hold off;
            
            for i = 1:obj.n_rows
                obj.DrawCircle(x1,obj.row_pos(i),'black')
            end
            
            for j = 1:obj.n_cols
                obj.DrawCircle(x2,obj.col_pos(j),'black');
            end
            
            
            
            obj.ApplyBasicBFormat();
            
        end
        
        function PlotBNestedMatrix(obj)
            cla;
            maxd = max(obj.n_rows,obj.n_cols);
            x1 = 1; x2 = 1+maxd*obj.horizontal_proportion;
            
            [~, obj.index_rows] = sort(sum(obj.matrix,2),'descend');
            [~, obj.index_cols] = sort(sum(obj.matrix,1),'descend'); 
            
            local_matrix = obj.matrix(obj.index_rows,obj.index_cols);
            
            hold on;
            for i = 1:obj.n_rows
                for j = 1:obj.n_cols
                    if(local_matrix(i,j)==1)
                        plot([1 x2],[obj.row_pos(i) obj.col_pos(j)],'Color',obj.link_color);
                    end
                end
            end
            hold off;
            
            for i = 1:obj.n_rows
                obj.DrawCircle(x1,obj.row_pos(i),obj.bead_color)
            end
            
            for j = 1:obj.n_cols
                obj.DrawCircle(x2,obj.col_pos(j),obj.bead_color);
            end
            
            obj.ApplyBasicBFormat();
        end
        
        function PlotBModularMatrix(obj)
            cla;
            maxd = max(obj.n_rows,obj.n_cols);
            x1 = 1; x2 = 1+maxd*obj.horizontal_proportion;
            
            if(isempty(obj.biweb))
                obj.biweb = Bipartite(obj.matrix);
            end
            if(obj.biweb.modules.done == 0)
                obj.biweb.modules.Detect();
            end
            
            obj.index_rows = obj.biweb.modules.index_rows;
            obj.index_cols = flipud(obj.biweb.modules.index_cols);
            
            row_mod = obj.biweb.modules.row_modules;
            col_mod = flipud(obj.biweb.modules.col_modules);
            
            local_matrix = obj.matrix(obj.index_rows,obj.index_cols);
            n_col = length(obj.colors);
                
            hold on;
            for i = 1:obj.n_rows
                for j = 1:obj.n_cols
                    if(local_matrix(i,j)==1)
                        if(row_mod(i)==col_mod(j))
                            plot([1 x2],[obj.row_pos(i) obj.col_pos(j)],'Color',obj.colors(mod(row_mod(i),n_col),:));
                        else
                            plot([1 x2],[obj.row_pos(i) obj.col_pos(j)],'Color','black');
                        end
                    end
                end
            end
            hold off;
            
            for i = 1:obj.n_rows
                obj.DrawCircle(x1,obj.row_pos(i),obj.colors(mod(row_mod(i),n_col),:));
            end
            
            for j = 1:obj.n_cols
                obj.DrawCircle(x2,obj.col_pos(j),obj.colors(mod(col_mod(j),n_col),:));
            end
            
            obj.ApplyBasicBFormat();
        end    
        
        function DrawLine(start_cord,end_cord,color)
           
            plot([start_cord(1) end_cord(1)],[start_cord(2) end_cord(2)],color,'LineWidth',1.0);
            
        end
        
        function obj = DrawCircle(obj,x,y,color)
            r = obj.radius;
            marg = obj.vertical_margin;
            rec = rectangle('Position',[x-r+marg,y-r+marg,2*(r-marg),2*(r-marg)],'Curvature',[1 1]);
            set(rec,'FaceColor',color);
            set(rec,'EdgeColor',color);
        end
        
        function obj = PlotMatrix(obj)
            
            cla;
            obj.index_rows = 1:obj.n_rows;
            obj.index_cols = 1:obj.n_cols;
                       
            for i = 1:obj.n_rows
                for j = 1:obj.n_cols
                    if(obj.matrix(i,j) > 0)
                        obj.DrawCell(i,j,obj.cell_color);
                    end
                end
            end
            
            obj.ApplyBasicFormat();
            
        end
        
        function obj = PlotNestedMatrix(obj)
            
            cla;
            [~, obj.index_rows] = sort(sum(obj.matrix,2),'descend');
            [~, obj.index_cols] = sort(sum(obj.matrix,1),'descend');
                        
            local_matrix = obj.matrix(obj.index_rows,obj.index_cols);
                       
            for i = 1:obj.n_rows
                for j = 1:obj.n_cols
                    if(local_matrix(i,j) > 0)
                        obj.DrawCell(i,j,obj.cell_color);
                    end
                end
            end
            
            obj.ApplyBasicFormat();
            
        end
        
        function obj = PlotModularMatrix(obj)
           
            cla;
            if(isempty(obj.biweb))
                obj.biweb = Bipartite(obj.matrix);
            end
            if(obj.biweb.modules.done == 0)
                obj.biweb.modules.Detect();
            end
            
            obj.index_rows = obj.biweb.modules.index_rows;
            obj.index_cols = obj.biweb.modules.index_cols;
            
            row_mod = obj.biweb.modules.row_modules;
            col_mod = obj.biweb.modules.col_modules;
            
            local_matrix = obj.matrix(obj.index_rows,obj.index_cols);
            n_col = length(obj.colors);
            
            for i = 1:obj.n_rows
                for j = 1:obj.n_cols
                    if(local_matrix(i,j)>0)
                        if(row_mod(i)==col_mod(j))
                            obj.DrawCell(i,j,obj.colors(mod(row_mod(i),n_col),:));
                        else
                            obj.DrawCell(i,j,obj.cell_color);
                        end
                    end
                end
            end
            
            obj.ApplyBasicFormat();
        end
        
        function obj = ApplyBasicFormat(obj)
           
            xlim([0.5-1.1*obj.margin,0.5+obj.n_cols+obj.margin]);
            ylim([0.5-obj.margin,0.5+obj.n_rows+obj.margin]);
            
            if(obj.use_labels)
               
                obj.FillLabels();
                
                for i = 1:obj.n_rows
                    text(0,obj.pos_y(i,1),obj.row_labels{i},'HorizontalAlignment','right','FontSize',obj.FontSize);
                end
                for j = 1:obj.n_cols
                    text(obj.pos_x(1,j),0,obj.col_labels{j},'HorizontalAlignment','right','Rotation',90,'FontSize',obj.FontSize);
                end
                
            end
            
            axis(obj.ax);
            set(gca,'Color',obj.back_color);
            set(gcf,'Color','white');
            set(gcf, 'InvertHardCopy', 'off'); %Do not plot in white the background
            box on;
            
        end
        
        function obj = ApplyBasicBFormat(obj)
            axis(obj.ax);
            maxd = max(obj.n_rows,obj.n_cols);
            x1 = 1; x2 = 1+maxd*obj.horizontal_proportion;
            xlim([x1-obj.radius x2+obj.radius]);
            ylim([1-obj.radius maxd+obj.radius]);
            
            if(obj.use_labels)
               
                obj.FillLabels();
                
                for i = 1:obj.n_rows
                    text(x1-obj.radius,obj.row_pos(i),obj.row_labels{i},'HorizontalAlignment','right','FontSize',obj.FontSize);
                end
                for j = 1:obj.n_cols
                    text(x2+obj.radius,obj.col_pos(j),obj.col_labels{j},'HorizontalAlignment','left','FontSize',obj.FontSize);
                end
                
            end
            
            set(gca,'Color','white');
            set(gcf,'Color','white');
            set(gca,'xcolor','white');
            set(gca,'ycolor','white');
            set(gcf, 'InvertHardCopy', 'off'); %Do not plot in white the background
        end
        
        function obj = FillLabels(obj)
            
            if(isempty(obj.biweb))
                obj.row_labels = cell(obj.n_rows,1);
                obj.col_labels = cell(obj.n_cols,1);
                for i = 1:obj.n_rows; obj.row_labels{i} = sprintf('row%03i',i); end;
                for j = 1:obj.n_cols; obj.col_labels{j} = sprintf('col%03i',j); end;
            else
                obj.row_labels = obj.biweb.row_labels;
                obj.col_labels = obj.biweb.col_labels;
            end
            
            obj.row_labels = obj.row_labels(obj.index_rows);
            obj.col_labels = obj.col_labels(obj.index_cols);
            
            set(gca,'xticklabel',[]);
            set(gca,'yticklabel',[]);
            set(gca,'YTick',[]);
            set(gca,'XTick',[]);
            
        end
        
        function obj = DrawBack(obj)
            
            set(gca,'Color',obj.back_color);
            
        end
        
        function obj = DrawCell(obj, i, j, color)
           
            rec = rectangle('Position',[obj.pos_x(i,j)-0.5+obj.margin,obj.pos_y(i,j)-0.5+obj.margin,1-2*obj.margin,1-2*obj.margin]);
            set(rec,'FaceColor',color);
            set(rec,'EdgeColor','none');

        end
        
    end
    
end