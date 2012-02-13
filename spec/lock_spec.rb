require "massive_sitemap/lock"

describe MassiveSitemap do
  describe "lock!" do
    let(:lock_file) { MassiveSitemap::LOCK_FILE }

    after do
      FileUtils.rm(lock_file) rescue nil
    end

    it 'does nothing without block' do
      MassiveSitemap.lock!
      ::File.exists?(lock_file).should be_false
    end

    it 'creates lockfile' do
      File.exists?(lock_file).should be_false
      MassiveSitemap.lock! do
        ::File.exists?(lock_file).should be_true
      end
    end

    it 'deletes lockfile' do
      MassiveSitemap.lock! {}
      ::File.exists?(lock_file).should be_false
    end

    it 'deletes lockfile in case of error' do
      expect do
        MassiveSitemap.lock! do
          raise ArgumentError
        end
      end.to raise_error
      ::File.exists?(lock_file).should be_false
    end

    it 'fails if lockfile exists' do
      ::File.open(lock_file, 'w',) {}
      expect do
        MassiveSitemap.lock! do
          puts "Hi"
        end
      end.to raise_error
    end
  end
end
