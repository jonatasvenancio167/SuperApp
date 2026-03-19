# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb
#
# Popula o banco com volume significativo para demonstrar performance em escala.
#
# Volume gerado:
#   - 3 escolas
#   - ~50 turmas (17 por escola)
#   - ~10.000 alunos
#   - ~15.000 responsáveis
#   - Vínculos aluno <-> turma e aluno <-> responsável
#   - Alguns comunicados já enviados com delivery_logs
#
# Estratégia de performance:
#   - insert_all em lotes para evitar N queries individuais
#   - Sem instanciar objetos ActiveRecord nos loops pesados
#   - UUIDs gerados no Ruby para montar os vínculos antes de inserir
#
# Tempo estimado: ~30-60s dependendo da máquina

require "securerandom"

puts "\nIniciando seed...\n\n"

# ─────────────────────────────────────────────────────────────
# CONFIGURAÇÕES
# ─────────────────────────────────────────────────────────────
SCHOOLS_COUNT    = 3
CLASSROOMS_EACH  = 17   # ~51 turmas no total
STUDENTS_COUNT   = 10_000
GUARDIANS_COUNT  = 15_000
BATCH_SIZE       = 1_000

GRADES = [
  "1º ano", "2º ano", "3º ano", "4º ano", "5º ano",
  "6º ano", "7º ano", "8º ano", "9º ano",
  "1º EM",  "2º EM",  "3º EM"
].freeze

CLASSROOM_NAMES = ("A".."Z").to_a.freeze

# ─────────────────────────────────────────────────────────────
# LIMPEZA (para poder rodar seeds múltiplas vezes)
# ─────────────────────────────────────────────────────────────
puts "Limpando dados anteriores..."

[
  DeliveryLog, AnnouncementStudent, AnnouncementClassroom,
  Announcement, StudentGuardian, StudentClassroom,
  Guardian, Student, Classroom, School
].each(&:delete_all)

# ─────────────────────────────────────────────────────────────
# ESCOLAS
# ─────────────────────────────────────────────────────────────
puts "Criando #{SCHOOLS_COUNT} escolas..."

school_data = SCHOOLS_COUNT.times.map do |i|
  {
    id:         SecureRandom.uuid,
    name:       "Escola Estadual #{Faker::Address.city}",
    code:       "ESC-#{(i + 1).to_s.rjust(3, "0")}",
    created_at: Time.current,
    updated_at: Time.current
  }
end

School.insert_all(school_data)
school_ids = School.pluck(:id)
puts "   ✓ #{School.count} escolas criadas"

# ─────────────────────────────────────────────────────────────
# TURMAS
# ─────────────────────────────────────────────────────────────
puts "Criando turmas (~#{SCHOOLS_COUNT * CLASSROOMS_EACH})..."

classroom_data = school_ids.flat_map do |school_id|
  CLASSROOMS_EACH.times.map do |i|
    {
      id:         SecureRandom.uuid,
      school_id:  school_id,
      name:       "Turma #{CLASSROOM_NAMES[i % CLASSROOM_NAMES.size]}",
      grade:      GRADES[i % GRADES.size],
      created_at: Time.current,
      updated_at: Time.current
    }
  end
end

Classroom.insert_all(classroom_data)
classroom_ids = Classroom.pluck(:id)
puts "   ✓ #{Classroom.count} turmas criadas"

# ─────────────────────────────────────────────────────────────
# ALUNOS
# ─────────────────────────────────────────────────────────────
puts "Criando #{STUDENTS_COUNT} alunos..."

student_ids = []

STUDENTS_COUNT.times.each_slice(BATCH_SIZE) do |batch|
  batch_data = batch.map do
    id = SecureRandom.uuid
    student_ids << id
    {
      id:         id,
      name:       Faker::Name.name,
      created_at: Time.current,
      updated_at: Time.current
    }
  end
  Student.insert_all(batch_data)
  print "."
end

puts "\n   ✓ #{Student.count} alunos criados"

# ─────────────────────────────────────────────────────────────
# RESPONSÁVEIS
# ─────────────────────────────────────────────────────────────
puts "Criando #{GUARDIANS_COUNT} responsáveis..."

guardian_ids = []

GUARDIANS_COUNT.times.each_slice(BATCH_SIZE) do |batch|
  batch_data = batch.map do
    id = SecureRandom.uuid
    guardian_ids << id
    {
      id:         id,
      name:       Faker::Name.name,
      email:      Faker::Internet.unique.email,
      created_at: Time.current,
      updated_at: Time.current
    }
  end
  Guardian.insert_all(batch_data)
  print "."
end

puts "\n   ✓ #{Guardian.count} responsáveis criados"

# ─────────────────────────────────────────────────────────────
# VÍNCULOS: alunos <-> turmas
# Cada aluno é alocado em 1 turma (distribuição round-robin)
# ─────────────────────────────────────────────────────────────
puts "Vinculando alunos às turmas..."

student_classroom_data = student_ids.each_with_index.map do |student_id, i|
  {
    id:           SecureRandom.uuid,
    student_id:   student_id,
    classroom_id: classroom_ids[i % classroom_ids.size],
    created_at:   Time.current,
    updated_at:   Time.current
  }
end

student_classroom_data.each_slice(BATCH_SIZE) do |batch|
  StudentClassroom.insert_all(batch)
  print "."
end

puts "\n   ✓ #{StudentClassroom.count} vínculos aluno-turma criados"

# ─────────────────────────────────────────────────────────────
# VÍNCULOS: alunos <-> responsáveis
# ~70% dos alunos têm 1 responsável
# ~30% têm 2 responsáveis (família com múltiplos filhos)
# Cada responsável tem no mínimo 1 aluno
# ─────────────────────────────────────────────────────────────
puts "Vinculando alunos aos responsáveis..."

student_guardian_data = []
guardian_idx          = 0

student_ids.each do |student_id|
  # Garante que o responsável principal existe
  guardian_id = guardian_ids[guardian_idx % guardian_ids.size]
  student_guardian_data << {
    id:          SecureRandom.uuid,
    student_id:  student_id,
    guardian_id: guardian_id,
    created_at:  Time.current,
    updated_at:  Time.current
  }
  guardian_idx += 1

  # 30% de chance de ter um segundo responsável
  if rand < 0.3
    second_guardian_id = guardian_ids[guardian_idx % guardian_ids.size]
    student_guardian_data << {
      id:          SecureRandom.uuid,
      student_id:  student_id,
      guardian_id: second_guardian_id,
      created_at:  Time.current,
      updated_at:  Time.current
    }
    guardian_idx += 1
  end
end

# Remove duplicatas (mesmo student_id + guardian_id) antes de inserir
student_guardian_data.uniq! { |r| [r[:student_id], r[:guardian_id]] }

student_guardian_data.each_slice(BATCH_SIZE) do |batch|
  StudentGuardian.insert_all(batch)
  print "."
end

puts "\n   ✓ #{StudentGuardian.count} vínculos aluno-responsável criados"

# ─────────────────────────────────────────────────────────────
# COMUNICADOS + DELIVERY LOGS
# Cria alguns comunicados por escola com logs realistas
# ─────────────────────────────────────────────────────────────
puts "Criando comunicados e logs de entrega..."

ANNOUNCEMENT_TEMPLATES = [
  { title: "Reunião de pais e mestres",      scope: "school"     },
  { title: "Calendário de provas bimestrais", scope: "school"     },
  { title: "Aviso de feriado escolar",        scope: "school"     },
  { title: "Atividade especial da turma",     scope: "classrooms" },
  { title: "Recuperação paralela",            scope: "classrooms" },
  { title: "Comunicado individual",           scope: "students"   },
].freeze

school_ids.each do |school_id|
  school_classrooms = Classroom.where(school_id: school_id).pluck(:id)
  school_students   = Student.joins(:classrooms)
                             .where(classrooms: { school_id: school_id })
                             .pluck("students.id")

  ANNOUNCEMENT_TEMPLATES.each do |template|
    announcement_id = SecureRandom.uuid
    sent_at         = Faker::Time.between(from: 30.days.ago, to: 1.day.ago)

    Announcement.insert({
      id:             announcement_id,
      school_id:      school_id,
      title:          template[:title],
      content:        Faker::Lorem.paragraphs(number: 3).join("\n\n"),
      scope:          template[:scope],
      status:         "sent",
      sent_at:        sent_at,
      created_at:     sent_at - 1.hour,
      updated_at:     sent_at
    })

    # Associa destinatários conforme o scope
    target_guardian_ids = case template[:scope]
    when "school"
      Guardian.joins(students: :classrooms)
              .where(classrooms: { school_id: school_id })
              .distinct
              .pluck(:id)

    when "classrooms"
      selected_classrooms = school_classrooms.sample(3)
      AnnouncementClassroom.insert_all(
        selected_classrooms.map do |cid|
          { id: SecureRandom.uuid, announcement_id: announcement_id,
            classroom_id: cid, created_at: Time.current, updated_at: Time.current }
        end
      )
      Guardian.joins(students: :classrooms)
              .where(classrooms: { id: selected_classrooms })
              .distinct
              .pluck(:id)

    when "students"
      selected_students = school_students.sample(20)
      AnnouncementStudent.insert_all(
        selected_students.map do |sid|
          { id: SecureRandom.uuid, announcement_id: announcement_id,
            student_id: sid, created_at: Time.current, updated_at: Time.current }
        end
      )
      Guardian.joins(:students)
              .where(students: { id: selected_students })
              .distinct
              .pluck(:id)
    end

    # Cria delivery_logs: ~65% lidos, ~35% não lidos
    delivery_log_data = target_guardian_ids.map do |guardian_id|
      is_read = rand < 0.65
      {
        id:              SecureRandom.uuid,
        announcement_id: announcement_id,
        guardian_id:     guardian_id,
        read:            is_read,
        read_at:         is_read ? Faker::Time.between(from: sent_at, to: Time.current) : nil,
        created_at:      sent_at,
        updated_at:      sent_at
      }
    end

    delivery_log_data.each_slice(BATCH_SIZE) do |batch|
      DeliveryLog.insert_all(batch)
    end

    print "."
  end
end

# ─────────────────────────────────────────────────────────────
# RESUMO FINAL
# ─────────────────────────────────────────────────────────────
puts "\n\n✅ Seed concluído!\n\n"
puts "─" * 40
puts "  Escolas:              #{School.count}"
puts "  Turmas:               #{Classroom.count}"
puts "  Alunos:               #{Student.count}"
puts "  Responsáveis:         #{Guardian.count}"
puts "  Vínculos aluno-turma: #{StudentClassroom.count}"
puts "  Vínculos aluno-resp.: #{StudentGuardian.count}"
puts "  Comunicados:          #{Announcement.count}"
puts "  Logs de entrega:      #{DeliveryLog.count}"
puts "─" * 40