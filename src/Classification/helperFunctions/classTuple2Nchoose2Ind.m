function y = classTuple2Nchoose2Ind(classTuple, n)

    if ( classTuple(2) <= classTuple(1) )
        error('second class index must be greater than first');
    end

    firstClass = classTuple(1);
    secondClass = classTuple(2);
    

    
    temp = n-1;
    y = 0;

    for i = 1:firstClass-1
        y = y + temp;
        temp = temp-1;
    end
    
    y = y + secondClass - firstClass;
    

end