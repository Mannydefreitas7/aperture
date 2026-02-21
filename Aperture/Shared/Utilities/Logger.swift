//
//  Logger.swift
//  Aperture
//
//  Created by Emmanuel on 2026-02-19.
//
import AppInformation
import os

/// General logging utility that wraps `os.Logger` and enriches messages
/// with call-site context (file, namespace, and function).
public enum Console {

    // Backing system logger
    private static let logger = Logger(
        subsystem: AppInfo.current.identifier,
        category: AppInfo.current.versioning.combined
    )

    // MARK: - Public API

    /// Logs an informational message.
    /// - Parameters:
    ///   - message: The message to log. Use string interpolation for values.
    ///   - fileID: Auto-filled file identifier (e.g., Module/Type.swift).
    ///   - function: Auto-filled function name.
    ///   - filePath: Auto-filled full file path for namespace extraction fallback.
    ///   - line: Auto-filled line number.
    public static func info(
        _ message: @autoclosure () -> String,
        fileID: StaticString = #fileID,
        function: StaticString = #function,
        filePath: StaticString = #filePath,
        line: UInt = #line
    ) {
        let context = makeContext(fileID: fileID, function: function, filePath: filePath, line: line)
        let msg = message()
        logger.log("[INFO] \(context) — \(msg)")
    }

    /// Logs a warning message.
    public static func warning(
        _ message: @autoclosure () -> String,
        fileID: StaticString = #fileID,
        function: StaticString = #function,
        filePath: StaticString = #filePath,
        line: UInt = #line
    ) {
        let context = makeContext(fileID: fileID, function: function, filePath: filePath, line: line)
        let msg = message()
        logger.warning("[WARN] \(context) — \(msg)")
    }

    /// Logs an error message.
    public static func error(
        _ message: @autoclosure () -> String,
        fileID: StaticString = #fileID,
        function: StaticString = #function,
        filePath: StaticString = #filePath,
        line: UInt = #line
    ) {
        let context = makeContext(fileID: fileID, function: function, filePath: filePath, line: line)
        let msg = message()
        logger.error("[ERROR] \(context) — \(msg)")
    }

    // MARK: - Helpers

    /// Builds a context string with file, namespace (best-effort), function, and line.
    /// Example output: "MyType.swift (MyType).myFunction():42"
    private static func makeContext(
        fileID: StaticString,
        function: StaticString,
        filePath: StaticString,
        line: UInt
    ) -> String {
        let fileIDString = String(describing: fileID)
        let functionString = String(describing: function)
        let filePathString = String(describing: filePath)

        let fileName = fileIDString.split(separator: "/").last.map(String.init) ?? fileIDString
        let namespace = inferNamespace(from: filePathString) ?? inferNamespace(from: fileIDString)
        let namespacePart = namespace.map { " (\($0))" } ?? ""

        return "\(fileName)\(namespacePart).\(functionString):\(line)"
    }

    /// Attempts to infer a namespace (type or folder) from a path-like string.
    /// This is a best-effort heuristic and may return nil if not derivable.
    private static func inferNamespace(from pathLike: String) -> String? {
        // Common Swift module/type hints can be in the last two components
        let components = pathLike.split(separator: "/").map(String.init)
        guard !components.isEmpty else { return nil }

        // Try to grab the immediate parent directory as a namespace hint
        if components.count >= 2 {
            let parent = components[components.count - 2]
            // Avoid generic folders often present in Swift projects
            let ignored = ["Sources", "Source", "Shared", "App", "Tests"]
            if !ignored.contains(parent) {
                return parent
            }
        }
        return nil
    }
}

