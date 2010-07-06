module VacuumCleaner
  class Railtie < Rails::Railtie
    config.after_initialize do
      ActiveRecord::Base.send(:include, VacuumCleaner::Normalizations)
    end
  end
end
