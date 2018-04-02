class Mapping < ApplicationRecord
    belongs_to :user
    belongs_to :join_db

    NON_VALIDATABLE_ATTRS = ["id", "created_at", "updated_at"] #or any other attribute that does not need validation
    VALIDATABLE_ATTRS = Mapping.attribute_names.reject{|attr| NON_VALIDATABLE_ATTRS.include?(attr)}  

    validates_presence_of VALIDATABLE_ATTRS

    def get_schema
        'public'
    end

    def get_table_name
        "mapping_#{table_one}_#{column_one}_#{table_two}_#{column_two}"
    end
end
