function fns = GetFileNames(string_include,string_exclude)
fns = dir(string_include);
fns = {fns.name}';

exclude_indices = logical(zeros(size(fns,1),1));

for i=1:size(fns,1)
    if ~isempty(strfind(fns{i},string_exclude))
        exclude_indices(i)=1;
    end
end

fns(exclude_indices) = [];