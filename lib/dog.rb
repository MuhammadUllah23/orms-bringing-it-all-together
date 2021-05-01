class Dog
    attr_accessor :name, :breed, :id

    def initialize(id: nil, name:, breed:)
      @id = id
      @name = name
      @breed = breed
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        );
      SQL
  
      DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP table dogs;")
    end

    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end

    def self.create(hash)
        dog = self.new(name: hash[:name], breed: hash[:breed])
        dog.save
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(x)
        sql = <<-SQL
        SELECT * 
        FROM dogs 
        WHERE id = ?
        SQL

        DB[:conn].execute(sql, x).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_by_name(name)
        sql = <<-SQL
          SELECT *
          FROM dogs
          WHERE name = ?
          LIMIT 1
        SQL
    
        DB[:conn].execute(sql, name).map do |row|
          self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(hash)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ? AND breed = ?
      SQL

      s = DB[:conn].execute(sql, hash[:name], hash[:breed]).flatten
      if s.empty? 
        dog = self.create(hash)
      else
        dog = self.new(id: s[0], name: s[1], breed: s[2])
      end
      dog
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)

    end
end