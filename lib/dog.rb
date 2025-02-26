class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    if self.id.nil?
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"

      DB[:conn].execute(sql, self.name, self.breed)

      @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
    else
      self.update
    end
    self
  end

  def self.create(name:, breed:)
    new_dog = self.new(name: name, breed: breed)
    new_dog.save
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"

    new_from_db(DB[:conn].execute(sql, id)[0])
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"

    existing_dog_row = DB[:conn].execute(sql, name, breed)

    if existing_dog_row.empty?
      self.create(name: name, breed: breed)
    else
      self.new_from_db(existing_dog_row[0])
    end
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"

    new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"

    DB[:conn].execute(sql, self.name, self.breed, self.id) unless self.id.nil?
  end

end