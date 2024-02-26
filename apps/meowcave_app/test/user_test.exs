defmodule UserApplicationTest do
  use ExUnit.Case
  # doctest Member.User

  alias Member.User
  alias Member.User.{Gender, Status, Locale}
  alias Member.Service.Register

  ## 偏向应用层面的测试

  test "create user" do
    user_model =
      [
        nickname: "Quagmire",
        email: "gleen@family.guys",
        password: "Gigitty, gigitty"
      ]
      |> Register.create_auth()
      |> Register.create_blank_user(%Locale{
        lang: "zh_Hans",
        timezone: "Etc/UTC"
      })

    # Update when map.
    user =
      User.update!(user_model, :nickname, "QgmrTheGigitty")
      |> User.update!(
        :gender,
        Gender.create()
        |> Gender.give!(:male)
      )
      |> User.update!(:info, "fxxk off, Brain.")

    assert user.nickname == "QgmrTheGigitty"
    assert Gender.get(user.gender) == :male
    assert user.info == "fxxk off, Brain."

    no_public_gender_user =
      User.remove_info!(user, :gender)
      |> User.remove_info!(:info)

    assert Gender.secret?(no_public_gender_user.gender)
    assert no_public_gender_user.info == ""
  end

  test "user status" do
    # Create
    new_user = %Status{value: :newbie}
    assert Status.valid?(new_user)

    # Activate
    normal_user = Status.activate(new_user)
    assert Status.normal?(normal_user)

    # Freeze
    freesed_user = Status.freeze(normal_user)
    assert not Status.normal?(freesed_user) and Status.interactive?(freesed_user)
    unfreesed_user = Status.activate(freesed_user)
    assert Status.normal?(unfreesed_user)

    # Block
    blocked_user = Status.block(normal_user)
    assert Status.blocked?(blocked_user)
  end

  test "user gender" do
    # Create
    new_user = Gender.create()
    mtf_user = %Gender{value: :non_bisexual}

    # Check
    assert not Gender.secret?(new_user)
    assert Gender.get(new_user) == :blank
    assert not Gender.bisexual?(mtf_user)

    # Modify
    hidden_user = Gender.hide(new_user)
    # 隐藏性别用户的性别也是 :blank
    assert Gender.get(hidden_user) == :blank
    explicit_user = Gender.expose(hidden_user)
    assert Gender.get(explicit_user) == :blank

    female_user = mtf_user |> Gender.update!(:female)
    assert Gender.get(female_user) == :female
  end

  ## 偏向细节的测试

  test "user update safe function" do
    default_user =
      Register.create_auth("A", "a@example.com", "123456")
      |> Register.create_blank_user(Register.create_locale("zh-Hans", "Asia/Shanghai"))

    # Member.User.update/3 with map
    new_gender =
      Gender.create()
      |> Gender.give!(:female)

    new_status = Status.activate(default_user.status)

    assert {:ok, user_updated_gender} =
             default_user
             |> User.update(:gender, new_gender)

    assert {:ok, user_updated_status} =
             user_updated_gender
             |> User.update(:status, new_status)

    assert {:error, _} =
             user_updated_status
             |> User.update(:info, %{Name: "A", University: "WCU(Wild Chicken University)"})

    # Member.User.update/3 with others
    assert {:ok, user_with_gender_updated} =
             user_updated_status
             |> User.update(:gender, :non_bisexual)

    assert user_with_gender_updated.gender.value == :non_bisexual

    assert {:error, _more_colorful_gender} =
             user_updated_gender
             |> User.update(:gender, :a_delightful_gender_with_full_of_pround)

    assert {:ok, user_with_status_updated} =
             user_updated_gender
             |> User.update(:status, :activate)

    assert user_with_status_updated.status.value == :normal

    assert {:error, _unknown_oprate} =
             user_updated_status
             |> User.update(:status, :eat)

    assert {:ok, user_with_nickname_updated} =
             user_with_gender_updated
             |> User.update(:nickname, "Aa")

    assert user_with_nickname_updated.nickname == "Aa"

    assert {:ok, user_with_info_updated} =
             user_with_nickname_updated
             |> User.update(:info, "不可以涩涩")

    assert String.contains?(user_with_info_updated.info, "涩")

    assert {:error, _tried_to_change_id} =
             user_with_info_updated
             |> User.update(:id, 8)
  end

  test "remove info safe function" do
    default_user =
      Register.create_auth("A", "a@example.com", "123456")
      |> Register.create_blank_user(Register.create_locale("zh-Hans", "Asia/Shanghai"))

    {:ok, updated_nickname_user} =
      default_user
      |> User.update(:nickname, "FaQ")

    {:ok, updated_info} =
      updated_nickname_user
      |> User.update(:info, "酸萝卜别吃！")

    {:ok, updated_gender} =
      updated_info
      |> User.update(:gender, :female)

    assert {:ok, %User{info: ""} = user_removed_info} =
             updated_gender
             |> User.remove_info(:info)

    assert {:ok, %User{nickname: ""}} =
             user_removed_info
             |> User.remove_info(:nickname)
  end
end
