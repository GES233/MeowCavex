defmodule UserTest do
  use ExUnit.Case
  # doctest Domain.User

  alias Domain.User
  alias Domain.User.{Status, Gender}

  test "create user" do
    user_info = [
      nickname: "Quagmire",
      email: "gleen@family.guys",
      password: "Gigitty, gigitty"
    ]

    user_model = %User{
      id: 1,
      nickname: "Quagmire",
      email: "gleen@family.guys",
      password: "Gigitty, gigitty",
      status: Status.create(),
      gender: Gender.create(),
      timezone: "UTC+0",  # TODO: Update.
      info: "",
      join_at: DateTime.utc_now()
    }

    # Update when map.
      user = User.update(user_model, :nickname, "QgmrTheGigitty")
      |> User.update(:gender, Gender.create() |> Gender.give(:male))
       |> User.update(:info, "fxxk off, Brain.")

    assert user.nickname == "QgmrTheGigitty"
    assert Gender.get(user.gender) == :male
    assert user.info == "fxxk off, Brain."

    no_public_gender_user = User.remove_info(user, :gender)
      |> User.remove_info(:info)

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
    assert Gender.get(hidden_user) == nil
    explicit_user = Gender.expose(hidden_user)
    assert Gender.get(explicit_user) == :blank

    female_user = mtf_user |> Gender.update(:female)
    assert Gender.get(female_user) == :female
  end
end
