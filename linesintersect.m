function [x_intersect,y_intersect] = linesintersect(l1,l2)

%fit linear polynomial
p1 = polyfit(l1(:,1),l1(:,2),1);
p2 = polyfit(l2(:,1),l2(:,2),1);
%calculate intersection
x_intersect = fzero(@(x) polyval(p1-p2,x),3);
y_intersect = polyval(p1,x_intersect);
    
end