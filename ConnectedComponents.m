clc;
clear all;
img_original = imread('Connected.bmp');
size_of_image = size(img_original);
Ttotal_rows = size_of_image(1);
Ttotal_cols = size_of_image(2);
Llabel = 1;
Num = 1;
Ttotal = 0;

%Thresholding loop
for i = 1:Ttotal_rows
    for j = 1:Ttotal_cols
        if(img_original(i,j) > 0)
            img_threshold(i,j) = 1;
        else
            img_threshold(i,j) = img_original(i,j);
        end
    end
end
%Component Llabeling 
for i = 1:Ttotal_rows
    for j = 1:Ttotal_cols
        if (i ==1)
            if(j==1)
                img_inter(i,j) = Llabel;
                Ttotal = Ttotal + 1;
            else
               if((img_threshold(i,j) == img_threshold(i,j-1)))
                   img_inter(i,j) = img_inter(i,j-1);
               else
                   Llabel = Llabel+1;
                   img_inter(i,j) = Llabel;
                   Ttotal = Ttotal +1;
               end
            end
        else
            if(j==1)
                if(img_threshold(i,j) == img_threshold(i-1,j))
                    img_inter(i,j) = img_inter(i-1,j);
                else
                    Llabel = Llabel+1;
                    img_inter(i,j) = Llabel;
                    Ttotal = Ttotal + 1;
                end
            else
                if(img_threshold(i,j) ~= img_threshold(i,j-1) && img_threshold(i,j) ~= img_threshold(i-1,j))
                    Llabel = Llabel+1;
                    img_inter(i,j) = Llabel;
                    Ttotal = Ttotal + 1;
                else
                    if(img_threshold(i,j) == img_threshold(i,j-1) && img_threshold(i,j) == img_threshold(i-1,j))
                        img_inter(i,j) = min(img_inter(i,j-1),img_inter(i-1,j));
                        if(img_inter(i,j-1) ~= img_inter(i-1,j))
                            Mmatch1(Num) = img_inter(i-1,j);
                            Mmatch2(Num) = img_inter(i,j-1);
                            Num = Num+1;
                        end
                    else
                        if(img_threshold(i,j) == img_threshold(i-1,j))
                            img_inter(i,j) = img_inter(i-1,j);
                        else
                            img_inter(i,j) = img_inter(i,j-1);
                        end
                    end
                end
            end
        end
    end
end

%Find the Equivalence Components 
Llabels = zeros(max(max(img_inter)),1);
pixel = 1;
for i = 1:length(Mmatch1)
   if(Llabels(Mmatch1(i)) == 0 && Llabels(Mmatch2(i)) == 0)
       Llabels(Mmatch1(i)) = min((Mmatch1(i)),(Mmatch2(i)));
       Llabels(Mmatch2(i)) = min((Mmatch1(i)),(Mmatch2(i)));
       elseif(Llabels(Mmatch1(i)) == 0 || Llabels(Mmatch2(i)) == 0)
       if(Llabels(Mmatch1(i)) ~= 0)
           Llabels(Mmatch2(i)) = Llabels(Mmatch1(i));
       else
           Llabels(Mmatch1(i)) = Llabels(Mmatch2(i));
       end
   elseif(Llabels(Mmatch1(i)) ~= 0 && Llabels(Mmatch2(i)) ~= 0)
       previous_value = max(Llabels(Mmatch1(i)),Llabels(Mmatch2(i)));
       Llabels(Mmatch1(i))= min(Llabels(Mmatch1(i)),Llabels(Mmatch2(i)));
       Llabels(Mmatch2(i)) = min(Llabels(Mmatch1(i)),Llabels(Mmatch2(i)));
       for k=1:length(Llabels)
           if(Llabels(k) == previous_value)
               Llabels(k) = min(Llabels(Mmatch1(i)),Llabels(Mmatch2(i)));
           end
       end
   end
end

%Final image with connected components
for i=1:Ttotal_rows
    for j=1:Ttotal_cols
        if(Llabels(img_inter(i,j)) == 0)
            img_final(i,j) = img_inter(i,j);
        else
            img_final(i,j) = Llabels(img_inter(i,j));
        end
    end
end

% To find the Ttotal Number of connected components
sum = 0;
for i=1:length(Llabels)
    if(Llabels(i) == 0)
        sum = sum+1;
    end
end

if (sum==0)
    no_of_connected_components = length(unique(Llabels));
else
    no_of_connected_components = length(unique(Llabels)) - 1 + sum;
end
max_value=max(max(img_final));
final = round(img_final*(256/max_value+1));
imshow(uint8(final));