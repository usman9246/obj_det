%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   DETECTING FOREGROUND WHITE OBJECTS IN THE BLACK BACKGROUND AND COLOUR
%   THEM

%   Author                   Usman Iqbal
%   Email                    usmaniqbal0001@gmail.com
%   Contact                  +923355251592
%   Last Modified            July 18, 2018

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
clc;

%% Getting the input image
disp('Getting the input from user')
[img_file, img_path] = uigetfile({'*.bmp';'*.png';'*.jpg'});
my_img = imread([img_path,img_file]);
if length(size(my_img))==3
    my_img = rgb2gray(my_img);
end
if ~islogical(my_img)
    my_img = imbinarize(my_img);
end

%% Checking the neighbouring pixels
disp('Checking the neighbouring pixels')
img = my_img;
[row, col] = size(my_img); %taking the size of the image
objects = 0; %count for number of objects
prob = 0; %count for contradictions occuring while assigning the numbers to pixel
img_main = my_img; %creating an empty matrix for intermediate processes
img_main(:,:) = 0;
img_main = double(img_main);
problem = 0;
for i=1:row
    for j=1:col
        check = 0; %check for whether the pixel has neighbouring pixel with foreground
        if img(i,j) == 1 %check for whether the pixel is on foreground
           
           if img(i,j-1) ~= 0 %check for left pixel
               img_main(i,j) = img_main(i,j-1); %assigning pixel the value of its left neighbouring pixel
               check_num = img_main(i,j-1); %storing the pixel value
               check = check + 1;
           end
           
           if img(i-1,j-1) ~= 0 %check for upper-left pixel
               if check ~= 0
                   if img_main(i-1,j-1) ~= check_num %check for contradicting neighbouring pixels
                       %storing the contradicting pixels
                       problem(prob+1,1) = img_main(i-1,j-1);
                       problem(prob+1,2) = check_num;
                       prob = prob + 1;
                   end
               else
                   img_main(i,j) = img_main(i-1,j-1); %assigning pixel the value of its upper-left neighbouring pixel
                   check_num = img_main(i-1,j-1); %storing the pixel value
                   check = check + 1;
               end
           end
           
           if img(i-1,j) ~= 0 %check for upper pixel
               if check ~= 0
                   if img_main(i-1,j) ~= check_num %check for contradicting neighbouring pixels
                       %storing the contradicting pixels
                       problem(prob+1,1) = img_main(i-1,j);
                       problem(prob+1,2) = check_num;
                       prob = prob + 1;
                   end
               else
                   img_main(i,j) = img_main(i-1,j); %assigning pixel the value of its upper neighbouring pixel
                   check_num = img_main(i-1,j); %storing the pixel value
                   check = check + 1;
               end
           end
           
           if img(i-1,j+1) ~= 0 %check for upper-right pixel
               if check ~= 0
                   if img_main(i-1,j+1) ~= check_num %check for contradicting neighbouring pixels
                       %storing the contradicting pixels
                       problem(prob+1,1) = img_main(i-1,j+1);
                       problem(prob+1,2) = check_num;
                       prob = prob + 1;
                   end
               else
                   img_main(i,j) = img_main(i-1,j+1); %assigning pixel the value of its upper-right neighbouring pixel
                   check_num = img_main(i-1,j+1); %storing the pixel value
                   check = check + 1;
               end
           end
           
           if check == 0
               %if there is no neighbouring pixel, assign a new object value
               img_main(i,j) = objects + 1;
               objects = objects + 1;
           end
           
        end
    end
end

%% Removing duplicate contradictions
if problem~=0
    prob_check = 1;
    final_problem(prob_check,:) = problem(1,:);
    for a=2:length(problem)
        if problem(a,1) ~= final_problem(prob_check,1) || problem(a,2) ~= final_problem(prob_check,2)
            final_problem(prob_check+1,:) = problem(a,:);
            prob_check = prob_check + 1;
        end
    end

    %sorting every row in ascending order
    final_problem = sort(final_problem,2);
end

%% Combining the contradicting pixels which belong to the same object
if problem~=0
    disp('Combining the contradicting pixels of same object')
    array(1,1) = final_problem(1,1);
    array(1,2) = final_problem(1,2);
    for i=2:length(final_problem)
        [a,b] = size(array);
        m = 1;
        while (m<=a)
            check_one = sum(ismember(array(m,:),final_problem(i,1)));
            check_two = sum(ismember(array(m,:),final_problem(i,2)));
            
            if check_one == 1
                if check_two ~= 1
                    array(m,b+1) = final_problem(i,2);
                    m = a; %to get out of the while loop if the value has been found and placed in the row
                end        
            
            elseif check_two == 1
                if check_one ~= 1
                    array(m,b+1) = final_problem(i,1);
                    m = a; %to get out of the while loop if the value has been found and placed in the row
                end
            
            else
                array(a+1,b+1) = final_problem(i,1);
                array(a+1,b+2) = final_problem(i,2);
            end
            m = m + 1;
        end
    end

    %sorting the rows in descending order
    array = sort(array,2,'descend');
end

%% Final step for putting together all the values which belong to same object
if problem~=0
    disp('Merging different values of same object')
    [r,c] = size(array);
    for i=2:r
        j=1;
        while j<=r
            if j~=i
                temp = transpose(nonzeros(array(i,:))); %taking the non-zero values of the row
                if sum(ismember(temp,array(j,:))) ~=0 %checking if any element in the above vector belongs to the row
                    %concatenating the values at the end of the row
                    for p=1:length(temp)
                        [r1,c1] = size(array);
                        array(j,c1+1)=temp(p);
                    end
                    array(i,:)=0;
                    j=r; %getting out if the row has been checked
                end
            end
            j=j+1;
        end
    end

    %sorting the rows in descending order
    array = sort(array,2,'descend');
end

%% Eliminating the duplicate values
if problem~=0
    array_i = unique(array(1,:));
    for i=2:r
        array_check = unique(array(i,:));
        for j=1:length(array_check)
            array_i(i,j) = array_check(j);
        end
    end

    %sorting the rows in descending order
    array_i = sort(array_i,2,'descend');
else
    array_i = [0 0];
end

%% Including objects with no contradicting pixels
for n=0:objects
    ch1 = ismember(array_i,n);
    s1 = sum(sum(ch1));
    if s1==0
        [r,c] = size(array_i);
        array_i(r+1,1) = n;
    end
end

[r,c] = size(array_i);

%% Removing the rows with zeros
array_i = array_i(any(array_i,2),:);

[r,c] = size(array_i);

%% Creating a color matrix for objects
colour_array = round(255*rand(r,3));

%% Assigning the RGB values to the pixels
disp('Assigning the RGB values to the pixels')
img_red = my_img;
img_red(:,:) = 0; %creating an empty matrix for red layer
img_red = double(img_red);
img_green = img_red; %creating an empty matrix for green layer
img_blue = img_red; %creating an empty matrix for blue layer

for i=1:row
    for j=1:col
        if img_main(i,j)~=0
            for k=1:r
                if sum(ismember(array_i(k,:),img_main(i,j))) %checking whether the pixel is part of the object
                    img_red(i,j) = colour_array(k,1);
                    img_green(i,j) = colour_array(k,2);
                    img_blue(i,j) = colour_array(k,3);
                end
            end
        end
    end
end

final_image = cat(3,img_red,img_green,img_blue); %concatenating the three colour layers

images = ['Total Objects: ', num2str(r)];
disp(images)
%% Displaying images 
figure;
subplot(121)
imshow(my_img); %displaying the original image
title('ORIGINAL IMAGE')
subplot(122)
imshow(mat2gray(final_image)) %converting the matrix into gray-scale image and displaying it
txt = ['COLOURED IMAGE [', num2str(r), ' objects]'];
title(txt)

disp('Done')