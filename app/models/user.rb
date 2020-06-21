class User < ApplicationRecord
  has_many :attendances, dependent: :destroy
  attr_accessor :ok_flag
  accepts_nested_attributes_for :attendances
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, uniqueness: true
  
  has_secure_password
  validates :password, presence: true, allow_nil: true
  
  
  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      # IDが見つかればレコードを呼び出し、見つからなければ新規作成
      user = find_by(id: row["id"]) || new
      # CSVからデータを取得し、設定する
      user.attributes = row.to_hash.slice(*updatable_attributes)
      user.password_confirmation = user.password
      # 保存する
      user.save
    end
  end
  
  def self.updatable_attributes
    ["name", "email", "affiliation", "employee_number", "uid", "basic_work_time", 
    "designated_work_start_time", "designated_work_end_time", "superior",
    "admin", "password"]
  end
  
  def authenticated?(remeber_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remeber_digest).is_password?(remer_token)
  end
  
end
