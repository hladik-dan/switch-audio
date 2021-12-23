import Foundation

class Argument {
    static func getValue(argument: String) -> String {
        if (!argument.contains("=")) {
            print("Argument couldn't be parsed!")
            exit(EXIT_FAILURE)
        }
        
        return String(argument.split(separator: "=")[1])
    }
}
