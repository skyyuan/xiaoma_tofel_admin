# encoding: utf-8

namespace :xiaoma do

  def import_dictation_group
    puts 'delete all dictation group'
    DictationGroup.delete_all

    puts 'import dictation group'
    DictationGroup.transaction do
      200.times do |idx|
        DictationGroup.create(name: idx + 1)
      end
    end
  end

  def import_oral_origins
    puts 'delete all oral origin and oral group'
    OralOrigin.delete_all
    OralGroup.delete_all

    puts 'improt oral origins and oral origin'
    # tpo start tpo33
    # tpo_num = 33
    tpo_num = 0
    # sequence_number = 198
    sequence_number = 0
    # oral_from = ['lecture4', 'lecture3', 'lecture2', 'lecture1', 'conversion2', 'conversion1' ]
    oral_from = ['conversion1', 'conversion2', 'lecture1', 'lecture2', 'lecture3', 'lecture4']
    OralOrigin.transaction do
      33.times do |origin_idx|
        # save oral origin
        tpo_num = tpo_num + 1
        oral_origin = OralOrigin.create(name: "tpo#{tpo_num}")
        # tpo_num = tpo_num - 1

        # save oral group
        # sequence_number = 0
        6.times do |group_idx|
          # sequence_number = OralGroup.count + 1
          sequence_number = sequence_number + 1
          OralGroup.create(sequence_number: sequence_number, name: oral_from[group_idx], oral_origin_id: oral_origin.id)
        end
      end

      outside_sequence_number = 199
      2.times do |idx|
        OralGroup.create(sequence_number: outside_sequence_number)
        outside_sequence_number = outside_sequence_number + 1
      end
    end
  end

  # def import_oral_group
  #   puts 'delete all oral group'
  #   OralGroup.delete_all

  #   puts 'import oral group'
  #   oral_from = ['conversion1', 'conversion2', 'lecture1', 'lecture2', 'lecture3', 'lecture4']
  #   tpo_num = 33
  #   OralGroup.transaction do
  #     200.times do |idx|
  #       oral_form_idx = idx % 6
  #       tpo_num = tpo_num + idx/6
  #       oral_origin_id = OralOrigin.where(name: "tpo#{tpo_num}").pluck(:id).first
  #       OralGroup.create(sequence_number: (idx + 1), name: oral_from[oral_form_idx], oral_origin_id: oral_origin_id)
  #     end
  #   end
  # end

  task import_dictation_and_oral_group_data: :environment do
    # import dictation group
    import_dictation_group

    # import oral origins
    import_oral_origins

    # import oral group
    # import_oral_group
  end
end
