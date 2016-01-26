module InstallRenamed
  def install_p(_, new_basename)
    super do |src, dst|
      if src.directory?
        dst
      else
        append_default_if_different(src, dst)
      end
    end
  end

  def cp_path_sub(pattern, replacement)
    super do |src, dst|
      append_default_if_different(src, dst)
    end
  end

  def +(path)
    super(path).extend(InstallRenamed)
  end

  def /(path)
    super(path).extend(InstallRenamed)
  end

  private

  def append_default_if_different(src, dst)
    if dst.file? && !FileUtils.identical?(src, dst)
      Pathname.new("#{dst}.default")
    else
      dst
    end
  end
end
