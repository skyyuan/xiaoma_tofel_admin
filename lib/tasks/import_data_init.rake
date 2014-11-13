# encoding: utf-8
#-*- encoding: utf-8 -*-
desc "Add vocabulary_groups"
task :add_vocabulary_groups => :environment  do
  (1..200).each do |i|
    VocabularyGroup.create(sequence_number: i)
  end
end

desc "Add grammar_types"
task :add_grammar_types => :environment  do
  ["重点","难点"].each do |i|
    GrammarType.create(name: i)
  end
end

desc "Add admin_user"
task :add_admin => :environment  do
  admin = Admin.new
  admin.email = 'admin@xiaoma.cn'
  admin.password = 'xiaomatf'
  admin.role = 1
  if admin.save
    p "ok"
  else
    p "error"
  end

end
