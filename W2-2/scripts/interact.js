async function main() {
    const [user] = await ethers.getSigners();
    console.log("User account address: ", user.address);
    
    const teacherContractAddress = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";

    const Teacher = await ethers.getContractFactory("Teacher");
    const teacher = Teacher.attach(teacherContractAddress);
    
    await teacher.setStudentScore("0x7c56f95cd1bbC1156F6252c08b5acb8c25bB455C", 85);
    const studentScore = await teacher.viewStudentScore("0x7c56f95cd1bbC1156F6252c08b5acb8c25bB455C");
    console.log("The setted score is: ", studentScore.toNumber());

    // const students = [
    //     { address: "0x7c56f95cd1bbC1156F6252c08b5acb8c25bB455C", score: 85 },
    //     { address: "0xDcD0083cC1CDB6B7611Fd7304dE53b9E026433C8", score: 90 },
    //     { address: "0xeBe1C3dbDDE660361420aF13Eb28166623cBB5A0", score: 95 },
    // ]

    // for (const student of students) {
    //     await teacher.setStudentScore(student.address, student.score);
    //     console.log(`Set score for student ${student.address}: ${student.score}.`);
    // }

    // const secondStudentScore = await teacher.viewStudentScore(students[1].address);
    // console.log(`Score of the second student: ${secondStudentScore}`);

    // for (const student of students) {
    //     const score = await teacher.viewStudentScore(student.address);
    //     console.log(`Student ${student.address}: ${student.score}`);
    // }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    })