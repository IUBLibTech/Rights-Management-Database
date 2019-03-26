class PodPhysicalObject < PodObject
  self.table_name = 'physical_objects'
  has_many :pod_digital_statuses, foreign_key: 'physical_object_id'
end
