require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class User
  attr_accessor :fname, :lname

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def self.find_by_id(id)
    user =  QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT *
      FROM users
      WHERE id = ?
    SQL

    return nil if user.empty?

    User.new(user.first)
  end

  def self.find_by_name(fname, lname)
    user =  QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT *
      FROM users
      WHERE fname = ? AND lname = ?
    SQL

    return nil if user.nil?

    user.map { |u| User.new(u)}
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
  end

  def average_karma
  end
end

class Question
  attr_accessor :title, :body, :author_id

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def self.find_by_id(id)
    question =  QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT *
      FROM questions
      WHERE id = ?
    SQL

    return nil if question.empty?

    Question.new(question.first)
  end

  def self.find_by_author_id(author_id)
    question =  QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT *
      FROM questions
      WHERE author_id = ?
    SQL

    return nil if question.empty?

    question.map { |q| Question.new(q)}
  end

  def author
    User.find_by_id(@author_id)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def self.most_followed(n)
  end

  def likers
  end

  def num_likes
  end

  def self.most_liked(n)
  end

end

class Reply
  attr_accessor :body, :question_id, :parent_id, :user_id

  def initialize(options)
    @id = options['id']
    @body = options['body']
    @question_id = options['question_id']
    @parent_id= options['parent_id']
    @user_id= options['user_id']
  end

  def self.find_by_id(id)
    reply =  QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT *
      FROM replies
      WHERE id = ?
    SQL

    return nil if reply.empty?

    Reply.new(reply.first)
  end

  def self.find_by_user_id(user_id)
    reply =  QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT *
      FROM replies
      WHERE user_id = ?
    SQL

    return nil if reply.empty?

    reply.map { |rep| Reply.new(rep)}
  end

  def self.find_by_question_id(question_id)
    reply =  QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT *
      FROM replies
      WHERE question_id = ?
    SQL

    return nil if reply.empty?

    reply.map { |rep| Reply.new(rep)}
  end

  def self.find_by_parent_id(parent_id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, parent_id)
      SELECT *
      FROM replies
      WHERE parent_id = ?
    SQL

    reply.map { |rep| Reply.new(rep) }
  end

  def author
    User.find_by_id(@user_id)
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    Reply.find_by_id(@parent_id)
  end

  def child_replies
    Reply.find_by_parent_id(@id)
  end

end

class QuestionFollow
  attr_accessor :question_id, :user_id

  def self.find_by_id(id)
    question_follow =  QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT *
      FROM question_follows
      WHERE id = ?
    SQL

    return nil if question_follow.empty?

    QuestionFollow.new(question_follow.first)
  end


  def self.followers_for_question_id(question_id)
    followers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT users.*
      FROM questions_follows
      JOIN users ON users.id = questions_follows.user_id
      JOIN questions ON questions.id = questions_follows.question_id
      WHERE questions.id = ?
    SQL

    followers.map { |f| User.new(f) }
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT questions.*
      FROM questions_follows
      JOIN users ON users.id = questions_follows.user_id
      JOIN questions ON questions.id = questions_follows.question_id
      WHERE users.id = ?
    SQL

    questions.map { |q| Question.new(q) }
  end

  def self.most_followed_questions(n)
  end
end


class QuestionLike
  attr_accessor :question_id, :user_id

  def self.find_by_id(id)
    likes =  QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT *
      FROM question_likes
      WHERE id = ?
    SQL

    return nil if likes.empty?

    Reply.new(likes.first)
  end

  def self.likers_for_question_id(question_id)
  end

  def self.num_likes_for_question_id(question_id)
  end

  def self.liked_questions_for_user_id(user_id)
  end

  def self.most_liked_questions(n)
  end
end
