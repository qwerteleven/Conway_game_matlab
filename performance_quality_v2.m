n = 700;
t = randi([0 1], n, n);
pause('on');

mask = [1 1 1; 1 0 1; 1 1 1];


while (true)
        
    t = update_state(t, mask);
    display(n, t);
end


function display(n, C)
    x = [0 n];
    y = [0 n];
    image(x, y, C .* 255)
    drawnow
end


function t = update_state(t, mask)
    poblations = conv2(t, mask, 'same');
    
    t_0 = t == 0;
    t_0 = poblations .* t_0 == 3;
             
    t_1 = t == 1;
    poblations_2 = poblations == 2;
    poblations_3 = poblations == 3;
    poblations_2_3 = poblations_2 + poblations_3;
    
    t_1 = t_1 .* poblations_2_3;
    
    t = t_0 + t_1;        
  
end

