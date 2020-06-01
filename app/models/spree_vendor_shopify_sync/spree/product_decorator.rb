Spree::Product.class_eval do
  has_and_belongs_to_many :certifications, -> { order(name: :asc) }, join_table: :certifications_spree_products, foreign_key: :spree_product_id
  has_and_belongs_to_many :categories, -> { order(name: :asc) }, optional: true
  has_many :qualities, through: :certifications
  has_many :reviews
  has_many :sync_logs, as: :syncable
  
  scope :with_qualities, ->(quality_ids) { joins(:qualities).where("certifications_qualities.quality_id IN (?)", quality_ids) }
  scope :belonging_to_vendor, ->(vendor_id) { where(vendor_id: vendor_id) }
  scope :reviewed, -> { where(state: 'reviewed') }
  scope :pending, -> { where(state: 'pending') }
  scope :denied, -> { where(state: 'denied') }
  scope :approved, -> { where(state: 'approved') }

  def all_certifications
    ((certifications || []) + (vendor.try(:certifications) || [])).uniq.sort_by &:name
  end

  def stars
    avg_rating.try(:round) || 0
  end

  def recalculate_rating
    self[:reviews_count] = reviews.reload.approved.count
    if reviews_count > 0
      self[:avg_rating] = reviews.approved.sum(:rating).to_f / reviews_count
    else
      self[:avg_rating] = 0
    end
    save
  end
end