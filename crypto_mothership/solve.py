import base64


def bit_flip(ciphertext_b64, target_plaintext, desired_plaintext):
    ciphertext = base64.b64decode(ciphertext_b64)
    iv = ciphertext[:16]
    blocks = [ciphertext[i:i + 16] for i in range(16, len(ciphertext), 16)]

    original = target_plaintext.encode()
    desired = desired_plaintext.encode()

    xor_diff = bytes(o ^ d for o, d in zip(original, desired))

    modified_iv = bytes(iv[i] ^ xor_diff[i] for i in range(len(xor_diff))) + iv[len(xor_diff):]

    modified_ciphertext = modified_iv + b''.join(blocks)
    return base64.b64encode(modified_ciphertext).decode()


def main():
    target_plaintext = "SHIP:SAFE"
    desired_plaintext = "SHIP:FIRE"

    while True:
        ciphertext_b64 = input("Enter encrypted message: ")

        modified_ciphertext_b64 = bit_flip(ciphertext_b64, target_plaintext, desired_plaintext)

        print(f"Modified ciphertext (submit this): {modified_ciphertext_b64}")


if __name__ == "__main__":
    main()
