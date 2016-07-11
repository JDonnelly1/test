function IM_moved = TimSURFMatch(IM_fixed,IM_move)
Pts_fixed=detectSURFFeatures(IM_fixed);
Pts_move=detectSURFFeatures(IM_move);
[features_fixed, valid_points_fixed] = extractFeatures(IM_fixed,Pts_fixed);
[features_move, valid_points_move] = extractFeatures(IM_move,Pts_move);
index_pairs=matchFeatures(features_fixed, features_move);
matched_fixed=valid_points_fixed(index_pairs(:,1));
matched_move=valid_points_move(index_pairs(:,2));
shift_val = round(median(matched_move.Location(:,:) -matched_fixed.Location(:,:),1));
if isnan(shift_val(1)) || abs(shift_val(1)) > 4 || abs(shift_val(2)) > 4
    fprintf('No shift! \n');
    fprintf('shift_val1 is %d\n',shift_val(1));
    fprintf('shift_val2 is %d\n',shift_val(2));
    IM_moved = IM_move;
else
fprintf('shift_val1 is %d\n',shift_val(1));
fprintf('shift_val2 is %d\n',shift_val(2));
IM_moved = zeros(size(IM_move),'like',IM_move);
IM_moved(:,5:end-5) = IM_move(:,5+shift_val(1):end-5+shift_val(1));
IM_moved(5:end-5,:) = IM_moved(5+shift_val(2):end-5+shift_val(2),:);
end

