#!/bin/bash

user_file="user.txt"
data_dir="/data1"
current_date="2024-10-10"
echo "Nhap pass ban muon xac nhan:"
read  password
# Kiểm tra sự tồn tại của tệp người dùng
if [ ! -f "$user_file" ]; then
    echo "Tệp $user_file không tồn tại."
    exit 1
fi

# Đọc từng dòng trong tệp và xử lý từng người dùng
for username in $(cat "$user_file"); do
    # Kiểm tra xem người dùng đã tồn tại hay chưa
    if id "$username" >/dev/null 2>&1; then
        # Kiểm tra nếu tài khoản inactive thì xóa
        if passwd -S "$username" | grep -q "P[PL]"; then
            userdel -r "$username"
            echo "Đã xóa tài khoản $username vì tài khoản inactive."
        else
            # Tạo thư mục /data/[user]
            mkdir -p "$data_dir/$username"
            echo "Đã tạo thư mục $data_dir/$username."
            
            # Thiết lập quyền cho thư mục
            chown -R "$username:$username" "$data_dir/$username"
        #    chmod -R 700 "$data_dir/$username"
            
       #     echo "Đã thiết lập quyền cho thư mục $data_dir/$username."
        fi
	
	 account_status=$(passwd -S "$username" | awk '{print $2}')
        if [ "$account_status" = "PS" ]; then
            # Nếu tài khoản khong bi khoa , khoa tai khoan
            sudo passwd -l "$username"
        fi


    else
        # Nếu người dùng chưa tồn tại, tạo mới với mật khẩu là "12345678"
        useradd -m -p  "$(openssl passwd -1 '$password')" "$username"
        echo "Đã tạo mới tài khoản $username với mật khẩu là $password ."
        
        # Tạo thư mục /data/[user]
        mkdir -p "$data_dir/$username"
        echo "Đã tạo thư mục $data_dir/$username."
        
        # Thiết lập quyền cho thư mục
       # chown -R "$username:$username" "$data_dir/$username"
      	 # chmod -R 700 "$data_dir/$username"
        
       # echo "Đã thiết lập quyền cho thư mục $data_dir/$username."
    fi
    #kiem tra ngay het han co phai ngay da cho hay khong, neu phai xoa tai khoan 
    expiration_date=$(sudo chage -l "$username" | grep "Account expires" | cut -d: -f2)
    if [ "$expiration_date" = "$current_date" ]; then
        sudo userdel -r "$username"
    fi
done

echo "Quá trình kiểm tra và xử lý đã hoàn thành."
