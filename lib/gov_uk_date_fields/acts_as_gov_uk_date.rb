module GovUkDateFields
  module ActsAsGovUkDate
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def acts_as_gov_uk_date(*date_fields)

        validate :validate_gov_uk_dates

        after_initialize :populate_gov_uk_dates

        cattr_accessor :_gov_uk_dates
        self._gov_uk_dates = date_fields


        # call valid? on each of the gov_uk date fields, and add error messages
        # into the errors hash if not valid
        #
        define_method(:validate_gov_uk_dates) do
          date_fields.each do |date_field|
            unless self.instance_variable_get("@_#{date_field}".to_sym).valid?
              errors[date_field] << "Invalid date"
            end
          end
        end

        define_method(:populate_gov_uk_dates) do
          self._gov_uk_dates.each do |date_field|
            GovUkDateFields::FormDate.set_from_date(self, date_field, self[date_field])
          end
        end



        # For each of the gov uk date fields, we have to define the following 
        # instance methods (assuming the date field name is dob):
        #
        # * dob       - retuns the date object (i.e. @_dob.date)
        # * dob=      - populatees @_dob
        # * dob_dd    - returns the day value for form popualtion
        # * dob_dd=   - sets the day value (used when updating from a form)
        # * dob_mm    - returns the month value for form popualtion
        # * dob_mm=   - sets the month value (used when updating from a form)
        # * dob_yyyy  - returns the year value for form popualtion
        # * dob_yyyy= - sets the year value (used when updating from a form)
        #
        date_fields.each do |field|

          # #dob -return @_dob.date
          define_method(field) do
            return self.instance_variable_get("@_#{field}".to_sym).date
          end

          # #dob=(date) = assigns a date to the GovukDateFields::FormDate object
          define_method("#{field}=") do |new_date|
            raise ArgumentError.new("#{new_date} is not a Date object") unless new_date.is_a?(Date) || new_date.nil?
            GovUkDateFields::FormDate.set_from_date(self, field, new_date)
          end

          # #dob_dd   - return the day value for form population
          define_method("#{field}_dd") do
            return self.instance_variable_get("@_#{field}".to_sym).dd
          end       

          # #dob_mm   - return the day value for form population
          define_method("#{field}_mm") do
            return self.instance_variable_get("@_#{field}".to_sym).mm
          end    

          # #dob_yyyy   - return the day value for form population
          define_method("#{field}_yyyy") do
            return self.instance_variable_get("@_#{field}".to_sym).yyyy
          end  

          # #dob_dd= - set the day part of the date (used in population of model from form)
          define_method("#{field}_dd=") do |day| 
            GovUkDateFields::FormDate.set_date_part(:dd, self, field, day)
          end   

          # #dob_dd= - set the day part of the date (used in population of model from form)
          define_method("#{field}_mm=") do |month| 
            GovUkDateFields::FormDate.set_date_part(:mm, self, field, month)
          end   

          # #dob_dd= - set the day part of the date (used in population of model from form)
          define_method("#{field}_yyyy=") do |year| 
            GovUkDateFields::FormDate.set_date_part(:yyyy, self, field, year)
          end   

        end

        after_initialize :populate_gov_uk_dates

        include GovUkDateFields::ActsAsGovUkDate::LocalInstanceMethods
      end
    end

    module LocalInstanceMethods
      def populate_gov_uk_dates
        self._gov_uk_dates.each do |field_name|
          GovUkDateFields::FormDate.set_from_date(self, field_name, self[field_name])
        end
      end

      # def populate_gov_uk_dates_from_form_fields
      #   MojDateFields::FormDate.set_from_date(self, :first_day_of_trial, self['first_day_of_trial'])
      # end
    end


  end
end

ActiveRecord::Base.send :include, GovUkDateFields::ActsAsGovUkDate
