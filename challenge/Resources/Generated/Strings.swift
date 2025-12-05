// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum Localized {
  internal enum Button {
    /// Buttons
    internal static let login = Localized.tr("Localizable", "Button.login", fallback: "Login")
    /// Tentar novamente
    internal static let retry = Localized.tr("Localizable", "Button.retry", fallback: "Tentar novamente")
  }
  internal enum Detail {
    internal enum Description {
      /// Descrição
      internal static let title = Localized.tr("Localizable", "Detail.description.title", fallback: "Descrição")
    }
  }
  internal enum Feedback {
    internal enum Error {
      /// Tivemos um problema ao carregar. Tente novamente.
      internal static let message = Localized.tr("Localizable", "Feedback.error.message", fallback: "Tivemos um problema ao carregar. Tente novamente.")
      /// Encontramos algum erro!
      internal static let title = Localized.tr("Localizable", "Feedback.error.title", fallback: "Encontramos algum erro!")
    }
  }
  internal enum Icon {
    /// magnifyingglass
    internal static let empty = Localized.tr("Localizable", "Icon.empty", fallback: "magnifyingglass")
    /// exclamationmark.triangle
    internal static let error = Localized.tr("Localizable", "Icon.error", fallback: "exclamationmark.triangle")
    /// magnifyingglass
    internal static let search = Localized.tr("Localizable", "Icon.search", fallback: "magnifyingglass")
  }
  internal enum List {
    /// Produtos
    internal static let title = Localized.tr("Localizable", "List.title", fallback: "Produtos")
    internal enum Feedback {
      internal enum Empty {
        /// Não encontramos resultados
        internal static let message = Localized.tr("Localizable", "List.Feedback.empty.message", fallback: "Não encontramos resultados")
        /// Nenhum resultado encontrado
        internal static let title = Localized.tr("Localizable", "List.Feedback.empty.title", fallback: "Nenhum resultado encontrado")
        internal enum Button {
          /// Limpar busca
          internal static let title = Localized.tr("Localizable", "List.Feedback.empty.button.title", fallback: "Limpar busca")
        }
        internal enum Message {
          /// Não encontramos resultados para %@
          internal static func query(_ p1: Any) -> String {
            return Localized.tr("Localizable", "List.Feedback.empty.message.query", String(describing: p1), fallback: "Não encontramos resultados para %@")
          }
        }
      }
      internal enum Error {
        internal enum InitialLoad {
          /// Não encontramos resultados
          internal static let message = Localized.tr("Localizable", "List.Feedback.error.initialLoad.message", fallback: "Não encontramos resultados")
          /// Nenhum resultado encontrado
          internal static let title = Localized.tr("Localizable", "List.Feedback.error.initialLoad.title", fallback: "Nenhum resultado encontrado")
        }
        internal enum Pagination {
          /// Não encontramos resultados
          internal static let message = Localized.tr("Localizable", "List.Feedback.error.pagination.message", fallback: "Não encontramos resultados")
          /// Nenhum resultado encontrado
          internal static let title = Localized.tr("Localizable", "List.Feedback.error.pagination.title", fallback: "Nenhum resultado encontrado")
        }
        internal enum Search {
          /// Não encontramos resultados
          internal static let message = Localized.tr("Localizable", "List.Feedback.error.search.message", fallback: "Não encontramos resultados")
          /// Nenhum resultado encontrado
          internal static let title = Localized.tr("Localizable", "List.Feedback.error.search.title", fallback: "Nenhum resultado encontrado")
        }
      }
    }
  }
  internal enum Login {
    /// Login
    internal static let title = Localized.tr("Localizable", "Login.title", fallback: "Login")
  }
  internal enum Search {
    /// Buscar produtos
    internal static let placeholder = Localized.tr("Localizable", "Search.placeholder", fallback: "Buscar produtos")
    /// Faça sua busca
    internal static let title = Localized.tr("Localizable", "Search.title", fallback: "Faça sua busca")
    internal enum Feedback {
      /// Necessário 3 characters
      internal static let error = Localized.tr("Localizable", "Search.Feedback.error", fallback: "Necessário 3 characters")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Localized {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
