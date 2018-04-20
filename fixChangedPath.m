function rp = fixChangedPath(rp, filename, pathname)

if ~strcmp(rp.parent_dir,pathname)
    rp.parent_dir=pathname;
    rp.im2_path=pathname;
end