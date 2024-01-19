# MeowCaveWeb

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

## 开发时注意的事情

### 关于 Gettext

参见 [Translations are dissapearing in umbrella #178 · elixir-gettext/gettext](https://github.com/elixir-gettext/gettext/issues/178) ~~（其实我也不知道怎么解决）~~，但是在 Umbrella 项目下确实不好处理。

```bash
cd ./apps/meowcave_web
mix gettext.extract
mix gettext.merge priv/gettext --locale zh_Hans
```
